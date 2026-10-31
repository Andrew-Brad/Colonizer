import { expect, test } from 'claude-code/testing'

import { bar, colorFor, paceBadge, pacePercent, timeLeft, toWindow, ttlUrgent } from '../hooks/register'

const MIN = 60_000
const HOUR = 60 * MIN

test('picks the five_hour window and parses its reset', () => {
  const w = toWindow([
    { kind: 'seven_day', percentUsed: 10 },
    { kind: 'five_hour', percentUsed: 42.5, resetsAt: '2026-10-18T15:00:00Z' },
  ])
  expect(w).toEqual({ percentUsed: 42.5, resetsAt: Date.parse('2026-10-18T15:00:00Z') })
  expect(toWindow([{ kind: 'seven_day', percentUsed: 10 }])).toBe(null)
})

test('bar fills proportionally across 18 cells and clamps', () => {
  expect(bar(0)).toBe('░'.repeat(18))
  expect(bar(50)).toBe('█'.repeat(9) + '░'.repeat(9))
  expect(bar(150)).toBe('█'.repeat(18))
})

test('pace marker overwrites the cell it lands in', () => {
  // 4% used, 62% through the window (the screenshot)
  expect(bar(4, 62)).toBe('█' + '░'.repeat(10) + '┃' + '░'.repeat(6))
  // marker inside the fill, and pinned to the last cell at 100%
  expect(bar(100, 50)).toBe('█'.repeat(9) + '┃' + '█'.repeat(8))
  expect(bar(0, 100)).toBe('░'.repeat(17) + '┃')
})

test('pace is the share of the 5h window elapsed', () => {
  expect(pacePercent(null, 0)).toBe(null)
  expect(pacePercent(5 * HOUR, 0)).toBe(0)
  expect(pacePercent(2 * HOUR, 0)).toBe(60)
  expect(pacePercent(-1, 0)).toBe(100)
  expect(pacePercent(9 * HOUR, 0)).toBe(0)
})

test('battery when ≥20 pts behind pace, fire when ≥20 ahead, blank between', () => {
  expect(paceBadge(4, 62)).toBe('🔋')
  expect(paceBadge(40, 60)).toBe('🔋')
  expect(paceBadge(41, 60)).toBe('  ')
  expect(paceBadge(79, 60)).toBe('  ')
  expect(paceBadge(80, 60)).toBe('🔥')
  expect(paceBadge(50, null)).toBe('  ')
})

test('color thresholds', () => {
  expect(colorFor(49)).toBe('success')
  expect(colorFor(50)).toBe('warning')
  expect(colorFor(80)).toBe('error')
})

test('TTL formatting is H:MM', () => {
  expect(timeLeft(null, 0)).toBe('?')
  expect(timeLeft(45 * MIN, 0)).toBe('0:45')
  expect(timeLeft(2 * HOUR + 5 * MIN, 0)).toBe('2:05')
  expect(timeLeft(-1000, 0)).toBe('0:00')
})

test('TTL turns urgent under 30 minutes', () => {
  expect(ttlUrgent(null, 0)).toBe(false)
  expect(ttlUrgent(30 * MIN, 0)).toBe(false)
  expect(ttlUrgent(29 * MIN, 0)).toBe(true)
})
