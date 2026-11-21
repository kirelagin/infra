import { TITLEBAR_AREAS } from '@hermes/plugin-sdk';
import { jsx } from 'react/jsx-runtime';

// Change this value to your preferred reading width.
const readingWidth = '110ch';
const css = `
[data-slot="aui_thread-content"]:not([data-thread-type="onboarding"]) {
  max-width: min(100%, ${readingWidth}) !important;
  margin-inline: auto;
}
`;

export default {
  id: 'hermes-reading-width',
  name: 'Chat Reading Width',
  register(ctx) {
    ctx.register({
      id: 'transcript-style',
      area: TITLEBAR_AREAS.left,
      render: () => jsx('style', { children: css }),
    });
  },
};
