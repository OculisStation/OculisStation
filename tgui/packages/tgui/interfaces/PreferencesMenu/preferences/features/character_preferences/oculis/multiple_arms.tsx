import type { FeatureChoiced } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const multiple_arms: FeatureChoiced = {
  name: 'How many additional sets of arms?',
  component: FeatureDropdownInput,
};
