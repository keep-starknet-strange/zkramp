import { deferredPromise } from 'src/utils/promise'

import { deleteConnection, getConnection, setConnection } from './db'

export enum BackgroundActionType {
  connect_request = 'connect_request',
  disconnect_request = 'disconnect_request',
  extract_data_request = 'extract_data_request',
}

type BackgroundAction = {
  type: BackgroundActionType
  data?: any
  meta?: any
  error?: boolean
}

export const initRPC = () => {
  // @ts-ignore
  chrome.runtime.onMessage.addListener((request: BackgroundAction, _sender, sendResponse) => {
    switch (request.type) {
      case BackgroundActionType.extract_data_request:
        handleExtractData(request, sendResponse)
        return true
      case BackgroundActionType.connect_request:
        handleConnect(request, sendResponse)
        return true
      case BackgroundActionType.disconnect_request:
        handleDisconnect(request, sendResponse)
        return true
      default:
        sendResponse({ error: 'Unknown action type' })
        break
    }
  })
}

async function handleConnect(request: BackgroundAction, sendResponse: (data?: any) => void) {
  try {
    const connection = await getConnection(request.data.origin)

    if (!connection) {
      const defer = deferredPromise()
      // Can be set to true/false if the user accepts/rejects the connection
      defer.resolve(true)
      await setConnection(request.data.origin)

      sendResponse(true)
    }
  } catch (error) {
    sendResponse({ error: 'Failed to connect' })
  }
}

async function handleDisconnect(request: BackgroundAction, sendResponse: (data?: any) => void) {
  try {
    const connection = await getConnection(request.data.origin)

    if (connection) {
      await deleteConnection(request.data.origin)
      sendResponse(true)
    } else {
      sendResponse({ error: 'No active connection found' })
    }
  } catch (error) {
    sendResponse({ error: 'Failed to disconnect' })
  }
}

function handleExtractData(request: BackgroundAction, sendResponse: (data?: any) => void) {
  if (!request.data.key) {
    return sendResponse({ error: 'Key is required' })
  }
  // Do something with the request.data.key
  // For now, just return a response
  // But you can use setters and getters to send public data to the content script
  let responseData = 'extension public data'
  if (request.data.key === 'secret') {
    responseData = 'extension secret data'
  }
  sendResponse({ response: responseData })
}
