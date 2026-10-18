import { expect, test } from 'claude-code/testing'

import { bar, colorFor, timeLeft, toWindow } from '../hooks/register'

test('picks the five_hour window and parses its reset', () => {
  const w = toWindow([
    { kind: 'seven_day', percentUsed: 10 },
    { kind: 'five_hour', percentUsed: 42.5, resetsAt: '2026-10-18T15:00:00Z' },
  ])
  expect(w).toEqual({ percentUsed: 42.5, resetsAt: Date.parse('2026-10-18T15:00:00Z') })
  expect(toWindow([{ kind: 'seven_day', percentUsed: 10 }])).toBe(null)
})

test('bar fills proportionally and clamps', () => {
  expect(bar(0)).toBe('░░░░░░░░░░')
  expect(bar(42)).toBe('████░░░░░░')
  expect(bar(150)).toBe('██████████')
})

test('color thresholds', () => {
  expect(colorFor(49)).toBe('success')
  expect(colorFor(50)).toBe('warning')
  expect(colorFor(80)).toBe('error')
})

test('time left formatting', () => {
  const now = 0
  expect(timeLeft(null, now)).toBe('?')
  expect(timeLeft(45 * 60_000, now)).toBe('45m')
  expect(timeLeft((2 * 60 + 5) * 60_000, now)).toBe('2h05m')
  expect(timeLeft(-1000, now)).toBe('0m')
})
