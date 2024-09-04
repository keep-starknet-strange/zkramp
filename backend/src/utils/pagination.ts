const CURSOR_SEPARATOR = '%'

export function fromCursorHash(cursor?: string): string[] {
  return cursor ? Buffer.from(cursor, 'base64').toString().split(CURSOR_SEPARATOR) : []
}

export function toCursorHash(...arr: string[]): string {
  return Buffer.from(arr.join(CURSOR_SEPARATOR)).toString('base64')
}
