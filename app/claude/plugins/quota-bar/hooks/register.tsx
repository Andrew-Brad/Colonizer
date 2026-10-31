import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, SessionRateLimit } from 'claude-code'

import type { Window } from '../types'

const BAR_CELLS = 18
const TICK_MS = 30_000
const WINDOW_MS = 5 * 60 * 60_000
/** Points ahead of / behind the uniform pace before 🔥 / 🔋 shows. */
const PACE_SLACK = 20
/** Under this many minutes left, the TTL turns yellow. */
const TTL_WARN_MINS = 30

const FILL = '█'
const TRACK = '░'
const MARKER = '┃'

const windowAtom = atom({ plugin: 'quota-bar', key: 'window' } as const, null)
const nowAtom = atom({ plugin: 'quota-bar', key: 'now' } as const, 0)

export const toWindow = (limits: readonly SessionRateLimit[]): Window | null => {
  const five = limits.find(l => l.kind === 'five_hour')
  if (!five) return null
  const resetsAt = five.resetsAt ? Date.parse(five.resetsAt) : NaN
  return { percentUsed: five.percentUsed, resetsAt: Number.isNaN(resetsAt) ? null : resetsAt }
}

export const colorFor = (pct: number) => (pct >= 80 ? 'error' : pct >= 50 ? 'warning' : 'success')

const clamp = (n: number, lo: number, hi: number) => Math.max(lo, Math.min(hi, n))

/** Where usage would sit (0–100) if spent uniformly across the 5h window; null when the reset is unknown. */
export const pacePercent = (resetsAt: number | null, now: number) => {
  if (resetsAt === null) return null
  const elapsed = WINDOW_MS - (resetsAt - now)
  return clamp((elapsed / WINDOW_MS) * 100, 0, 100)
}

export type Segment = { kind: 'fill' | 'track' | 'marker'; text: string }

/** The bar as runs of fill / track, with the pace marker overwriting the cell it lands in. */
export const segments = (pct: number, pace: number | null): Segment[] => {
  const filled = clamp(Math.round((pct / 100) * BAR_CELLS), 0, BAR_CELLS)
  const markerAt = pace === null ? -1 : clamp(Math.floor((pace / 100) * BAR_CELLS), 0, BAR_CELLS - 1)
  const out: Segment[] = []
  for (let i = 0; i < BAR_CELLS; i++) {
    const kind = i === markerAt ? 'marker' : i < filled ? 'fill' : 'track'
    const ch = kind === 'marker' ? MARKER : kind === 'fill' ? FILL : TRACK
    const last = out[out.length - 1]
    if (last?.kind === kind) last.text += ch
    else out.push({ kind, text: ch })
  }
  return out
}

export const bar = (pct: number, pace: number | null = null) =>
  segments(pct, pace).map(s => s.text).join('')

/** 🔋 well behind pace, 🔥 well ahead, two blank columns otherwise (keeps the text after it still). */
export const paceBadge = (pct: number, pace: number | null) => {
  if (pace === null) return '  '
  if (pct <= pace - PACE_SLACK) return '🔋'
  if (pct >= pace + PACE_SLACK) return '🔥'
  return '  '
}

const minsLeft = (resetsAt: number, now: number) => Math.max(0, Math.ceil((resetsAt - now) / 60_000))

export const timeLeft = (resetsAt: number | null, now: number) => {
  if (resetsAt === null) return '?'
  const mins = minsLeft(resetsAt, now)
  return `${Math.floor(mins / 60)}:${String(mins % 60).padStart(2, '0')}`
}

export const ttlUrgent = (resetsAt: number | null, now: number) =>
  resetsAt !== null && minsLeft(resetsAt, now) < TTL_WARN_MINS

async function refresh($: EngineInterface, limits?: readonly SessionRateLimit[]) {
  const rateLimits = limits ?? (await $.session.usage()).rateLimits
  const now = await $.clock.now()
  await update($, windowAtom, () => toWindow(rateLimits))
  await update($, nowAtom, () => now)
}

export const register: Register = on => {

  on('session.start', async ($, e, next) => {
    await refresh($)
    // Keep the countdown and pace marker moving between API responses
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
    const pace = pacePercent(win.resetsAt, now)
    const color = colorFor(pct)
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box>
        {segments(pct, pace).map((s, i) =>
          s.kind === 'fill' ? <Text key={`s${i}`} color={color}>{s.text}</Text>
          : s.kind === 'marker' ? <Text key={`s${i}`} color="text" weight="bold">{s.text}</Text>
          : <Text key={`s${i}`} dimColor>{s.text}</Text>,
        )}
        <Text> {paceBadge(pct, pace)} </Text>
        <Text color={color}>{Math.round(pct)}% 5h</Text>
        <Text dimColor> · </Text>
        {ttlUrgent(win.resetsAt, now)
          ? <Text color="warning" weight="bold">TTL {timeLeft(win.resetsAt, now)}</Text>
          : <Text dimColor>TTL {timeLeft(win.resetsAt, now)}</Text>}
      </Box>
    )
  })
}
