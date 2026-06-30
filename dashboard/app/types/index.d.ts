export type Period = 'daily' | 'weekly' | 'monthly'

export interface Range {
  start: Date
  end: Date
}

/** Stat card — used by HomeStats component. */
export interface Stat {
  title: string
  icon: string
  value: number | string
  variation: number
}
