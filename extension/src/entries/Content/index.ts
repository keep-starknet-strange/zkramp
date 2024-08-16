import { BackgroundActionType } from '../Background/rpc'
import { ContentScriptRequest, ContentScriptTypes, RPCServer } from './rpc'
;(async () => {
  loadScript('content.js')
  const server = new RPCServer()

  const sendMessageAsync = (message: any) => {
    return new Promise((resolve, reject) => {
      chrome.runtime.sendMessage(message, (response) => {
        if (chrome.runtime.lastError) {
          reject(chrome.runtime.lastError)
        } else {
          resolve(response)
        }
      })
    })
  }

  server.on(ContentScriptTypes.connect, async () => {
    // @ts-ignore
    const connected = await sendMessageAsync({
      type: BackgroundActionType.connect_request,
      data: {
        ...getOriginData(),
      },
    })

    if (!connected) throw new Error('user rejected.')

    return connected
  })

  server.on(ContentScriptTypes.disconnect, async () => {
    // @ts-ignore
    const disconnected = await sendMessageAsync({
      type: BackgroundActionType.disconnect_request,
      data: {
        ...getOriginData(),
      },
    })

    if (!disconnected) throw new Error('error.')

    return disconnected
  })

  server.on(ContentScriptTypes.extract_data, async (request: ContentScriptRequest<{ key: string }>) => {
    const { key } = request.params || {}

    if (!key) throw new Error('params must include key of the request')

    // @ts-ignore
    const response = await chrome.runtime.sendMessage({
      type: BackgroundActionType.extract_data_request,
      data: {
        ...getOriginData(),
        key,
      },
    })

    return response
  })
})()

function loadScript(filename: string) {
  //@ts-ignore
  const url = chrome.runtime.getURL(filename)
  const script = document.createElement('script')
  script.setAttribute('type', 'text/javascript')
  script.setAttribute('src', url)
  document.body.appendChild(script)
}

function getOriginData() {
  return {
    origin: window.origin,
  }
}
