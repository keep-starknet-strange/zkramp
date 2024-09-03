import { ContentScriptTypes, RPCClient } from './rpc'

const client = new RPCClient()

class Zkramp {
  async extractData(key: string) {
    const resp = await client.call(ContentScriptTypes.extract_data, {
      key,
    })

    return resp
  }

  async disconnect() {
    const resp = await client.call(ContentScriptTypes.disconnect)

    return resp
  }
}

const connect = async () => {
  const resp = await client.call(ContentScriptTypes.connect)

  if (resp) {
    return new Zkramp()
  }

  return null
}

// @ts-ignore
window.zkramp = {
  connect,
}
