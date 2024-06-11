import Foundation
import Capacitor
import AcuantiOSSDKV11
import AcuantHGLiveness
import AcuantPassiveLiveness
import AcuantCommon


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(IDVPlugin)
public class IDVPlugin: CAPPlugin {

    @objc func checkActiveLiveness(_ call: CAPPluginCall) {
        self.call = call
        // Check if active liveness is supported
        // Active liveness uses blinking
        DispatchQueue.main.async {
            guard let viewController = self.bridge?.viewController else {
                call.reject("Unable to get the current view controller")
                return
            }

            let liveFaceViewController = FaceLivenessCameraController()
            liveFaceViewController.delegate = self // Ensure IDVPlugin conforms to AcuantHGLiveFaceCaptureDelegate

            viewController.present(liveFaceViewController, animated: true, completion: nil)
        }

    }

    @objc func takeSelfiePhoto(_ call: CAPPluginCall) {
          self.call = call

          // Passive liveness
          DispatchQueue.main.async {
              guard let viewController = self.bridge?.viewController else {
                  call.reject("Unable to get the current view controller")
                  return
              }

              let faceCaptureController = FaceCaptureController()
              let options = FaceCameraOptions(showOval: true)
              faceCaptureController.options = options

              // Callback once face has been captured
              faceCaptureController.callback = { [weak self] faceCaptureResult in
                guard let self = self else { return }
                print("Result captured")

                if let result = faceCaptureResult {
                    let faceCapturedImage = result.image
                    var livenessString = ""
                    // Process passive liveness
                    PassiveLiveness.postLiveness(request: AcuantLivenessRequest(jpegData: result.jpegData)) { [weak self] result, error in
                        if let livenessResult = result,
                           (livenessResult.result == AcuantLivenessAssessment.live || livenessResult.result == AcuantLivenessAssessment.notLive) {
                            livenessString = "Liveness : \(livenessResult.result.rawValue)"
                        } else {
                            livenessString = "Liveness : \(result?.result.rawValue ?? "Unknown") \(error?.errorCode?.rawValue ?? "") \(error?.description ?? "")"
                        }
                    }
                    // If we need to process facial match with a document
                    // see self.processFacialMatch(imageData: result.jpegData) in the sample app
                }

                self.call?.resolve(["value": faceCaptureResult])
                viewController.dismiss(animated: true)

              }

              viewController.present(faceCaptureController, animated: true, completion: nil)
          }

    }

    @objc func takeIDPhotoFront(_ call: CAPPluginCall) {
        // Cusomize messaging here
        self.presentDocCapture(call)
    }

    @objc func takeIDPhotoBack(_ call: CAPPluginCall) {
        // Cusomize messaging here
        self.presentDocCapture(call)
    }


    private let implementation = IDV()

    private var call: CAPPluginCall?

    @objc func presentDocCapture(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let viewController = self.bridge?.viewController else {
                call.reject("Unable to get the current view controller")
                return
            }

            let textForState: (DocumentCameraState) -> String = { state in
              switch state {
              case .align: return "ALIGN"
              case .moveCloser: return "MOVE CLOSER"
              case .tooClose: return "TOO CLOSE"
              case .steady: return "HOLD STEADY"
              case .hold: return "HOLD"
              case .capture: return "CAPTURING"
              @unknown default: return ""
              }
            }
            let options = DocumentCameraOptions(hideNavigationBar: false, autoCapture: false, textForState: textForState)
            let documentCameraViewController = DocumentCameraViewController(options: options)
            documentCameraViewController.delegate = self
            

            viewController.present(documentCameraViewController, animated: true, completion: nil)
        }
    }

}

// Extension to conform to AcuantHGLiveFaceCaptureDelegate
extension IDVPlugin: HGLivenessDelegate {
    public func liveFaceCaptured(result: AcuantHGLiveness.HGLivenessResult?) {
        // Directly using your condition for checking result
        if result?.jpegData != nil {
            print("Your face captured")

            // Assuming the presentation of FaceLivenessCameraController was made on the main thread
            self.call?.resolve(["value": result]);
//            DispatchQueue.main.async {
//                // First, dismiss the FaceLivenessCameraController
//                self.bridge?.viewController?.dismiss(animated: true, completion: {
//                    // Once dismissed, present the DocumentCameraViewController
//                    // Ensure 'self.call' is safely unwrapped if required
//                    if let call = self.call {
//                        self.presentDocCapture(call)
//                    }
//                })
//            }
        } else {
            print("Face capture failed or was cancelled")
            self.call?.reject("Face capture failed or was cancelled")
            // Optionally handle the failure, e.g., by rejecting 'self.call'
        }
    }
    // Implement delegate methods here
}

extension IDVPlugin: DocumentCameraViewControllerDelegate {
    public func onCaptured(image: Image, barcodeString: String?) {
        print(image.data)
        if let result = image.image {
            print("Doc captured")
            self.bridge?.viewController?.dismiss(animated: true, completion: nil);
            // NOTE(DM): we may want to return a byte array instead somehow
            self.call?.resolve((["value": result.jpegData(compressionQuality: 1)?.base64EncodedString()]))
        } else {
            self.call?.resolve((["value": nil]))
        }
    }
}
