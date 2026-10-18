export type Window = { percentUsed: number; resetsAt: number | null }

declare module 'claude-code' {
  interface PluginState {
    'quota-bar': { window: Window | null; now: number }
  }
}
