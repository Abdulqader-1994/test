import { createHttpLink } from '@apollo/client/link/http/index.js'
import { InMemoryCache } from '@apollo/client/cache/index.js'


export /* async */ function getClientOptions(
  // eslint-disable-next-line no-unused-vars
  /* {app, router, ...} */ options
) {
  const devServer = 'http://127.0.0.1:8787/api';
  const depServer = 'https://server.mar1994-egypt.workers.dev/api'
  const httpLink = createHttpLink({ uri: devServer })

  return Object.assign(
    // General options.
    {
      link: httpLink,

      cache: new InMemoryCache(),

      defaultOptions: {
        watchQuery: {
          fetchPolicy: 'network-only',
        },
        query: {
          fetchPolicy: 'network-only',
        },
        mutate: {
          fetchPolicy: 'network-only',
        },
      },
    },

    // Specific Quasar mode options.
    process.env.MODE === 'spa'
      ? {
        //
      }
      : {},
    process.env.MODE === 'ssr'
      ? {
        //
      }
      : {},
    process.env.MODE === 'pwa'
      ? {
        //
      }
      : {},
    process.env.MODE === 'bex'
      ? {
        //
      }
      : {},
    process.env.MODE === 'cordova'
      ? {
        //
      }
      : {},
    process.env.MODE === 'capacitor'
      ? {
        //
      }
      : {},
    process.env.MODE === 'electron'
      ? {
        //
      }
      : {},

    // dev/prod options.
    process.env.DEV
      ? {
        //
      }
      : {},
    process.env.PROD
      ? {
        //
      }
      : {},

    // For ssr mode, when on server.
    process.env.MODE === 'ssr' && process.env.SERVER
      ? {
        ssrMode: true,
      }
      : {},
    // For ssr mode, when on client.
    process.env.MODE === 'ssr' && process.env.CLIENT
      ? {
        ssrForceFetchDelay: 100,
      }
      : {}
  )
}
