/** Shared formatters — used across shop pages, formerly copy-pasted in 9 files. */

export function formatPrice(price: string | number | null | undefined): string {
  const n = Number(price)
  if (Number.isNaN(n)) return '¥0.00'
  return `¥${n.toFixed(2)}`
}

export function formatDate(value: string | Date | null | undefined): string {
  if (!value) return ''
  const d = typeof value === 'string' ? new Date(value) : value
  if (Number.isNaN(d.getTime())) return ''
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

export type StarState = 'full' | 'half' | 'empty'

export function renderStars(rating: number): StarState[] {
  const stars: StarState[] = []
  for (let i = 1; i <= 5; i++) {
    if (i <= Math.floor(rating)) stars.push('full')
    else if (i - rating < 1) stars.push('half')
    else stars.push('empty')
  }
  return stars
}
