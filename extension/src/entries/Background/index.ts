import { initRPC } from './rpc'
;(async () => {
  try {
    // @ts-ignore
    chrome.sidePanel.setPanelBehavior({ openPanelOnActionClick: true }).catch((error: any) => console.error(error))
    initRPC()
  } catch (error) {
    console.error('Error when initializing RPC:', error)
  }
})()
