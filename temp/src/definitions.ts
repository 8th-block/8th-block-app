export interface IDVPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  takeSelfiePhoto(): Promise<{ value: any }>;
  takeIDPhotoFront(): Promise<{ value: any }>;
  takeIDPhotoBack(): Promise<{ value: any }>;
}
