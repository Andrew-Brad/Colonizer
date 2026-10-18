import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, SessionRateLimit } from 'claude-code'

import type { Window } from '../types'

const BAR_CELLS = 10
const TICK_MS = 30_000

const windowAtom = atom({ plugin: 'quota-bar', key: 'window' } as const, null)
const nowAtom = atom({ plugin: 'quota-bar', key: 'now' } as const, 0)

export const toWindow = (limits: readonly SessionRateLimit[]): Window | null => {
  const five = limits.find(l => l.kind === 'five_hour')
  if (!five) return null
  const resetsAt = five.resetsAt ? Date.parse(five.resetsAt) : NaN
  return { percentUsed: five.percentUsed, resetsAt: Number.isNaN(resetsAt) ? null : resetsAt }
}

export const colorFor = (pct: number) => (pct >= 80 ? 'error' : pct >= 50 ? 'warning' : 'success')

export const bar = (pct: number) => {
  const filled = Math.max(0, Math.min(BAR_CELLS, Math.round((pct / 100) * BAR_CELLS)))
  return '█'.repeat(filled) + '░'.repeat(BAR_CELLS - filled)
}

export const timeLeft = (resetsAt: number | null, now: number) => {
  if (resetsAt === null) return '?'
  const mins = Math.max(0, Math.ceil((resetsAt - now) / 60_000))
  return mins >= 60 ? `${Math.floor(mins / 60)}h${String(mins % 60).padStart(2, '0')}m` : `${mins}m`
}

async function refresh($: EngineInterface, limits?: readonly SessionRateLimit[]) {
  const rateLimits = limits ?? (await $.session.usage()).rateLimits
  const now = await $.clock.now()
  await update($, windowAtom, () => toWindow(rateLimits))
  await update($, nowAtom, () => now)
}

export const register: Register = on => {

  on('session.start', async ($, e, next) => {
    await refresh($)
    // Keep the countdown moving between API responses
    $.clock.every(TICK_MS, () => void refresh($))
    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('rateLimits')) await refresh($, e.rateLimits)
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const win = await read($, windowAtom)
    if (e.props.hasSurvey || win === null) return next(e)

    const now = await read($, nowAtom)
    const pct = win.percentUsed
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box>
        <Text dimColor>5h </Text>
        <Text color={colorFor(pct)}>{bar(pct)}</Text>
        <Text color={colorFor(pct)}> {Math.round(pct)}%</Text>
        <Text dimColor> · {timeLeft(win.resetsAt, now)} left</Text>
      </Box>
    )
  })
}
