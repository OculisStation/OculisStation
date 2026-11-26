// THIS IS A NOVA SECTOR UI FILE
import {
  CheckboxInput,
  type Feature,
  type FeatureChoicedServerData,
  type FeatureToggle,
  FeatureTriColorInput,
  type FeatureValueProps,
} from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const halo_toggle: FeatureToggle = {
  name: 'Halo',
  component: CheckboxInput,
};

export const feature_halo: Feature<string> = {
  name: 'Halo Selection',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const halo_color: Feature<string[]> = {
  name: 'Halo Colors',
  component: FeatureTriColorInput,
};

export const halo_emissive: Feature<boolean> = {
  name: 'Halo Emissives',
  description: 'Emissive parts glow in the dark.',
  component: CheckboxInput,
};
