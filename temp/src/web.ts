import { WebPlugin } from '@capacitor/core';

import type { IDVPlugin } from './definitions';

export class IDVWeb extends WebPlugin implements IDVPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async takeSelfiePhoto(): Promise<{ value: any }> {
    console.log('takeSelfiePhoto');
    return { value: null };
  }

  async takeIDPhotoFront(): Promise<{ value: any }> {
    console.log('takeIDPhotoFront');
    return { value: null };
  }

  async takeIDPhotoBack(): Promise<{ value: any }> {
    console.log('takeIDPhotoBack');
    return { value: null };
  }
}
