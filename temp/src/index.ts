import { registerPlugin } from '@capacitor/core';

import type { IDVPlugin } from './definitions';

const IDV = registerPlugin<IDVPlugin>('IDV', {
  web: () => import('./web').then(m => new m.IDVWeb()),
});

export * from './definitions';
export { IDV };
