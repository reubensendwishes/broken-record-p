export type Field<T = string> = {
    id: T
    type: string
    label: string
    helper?: string
    maxLength?: number
}

export type Fields<T = string> = [Field<T>, ...Field<T>[]]

export type Validator = (value: string) => string | Promise<string>

export type Validators<T extends string = string> = Record<T, Validator>

export type FabItem<T = string> = {
    name: T
}

export type FabItems<T = string> = [FabItem<T>, ...FabItem<T>[]]

export type DraggableItem<T = Record<string, unknown>> = {
    id: string
    title: string
    sort: number
    children: DraggableItem<T>[]
} & T
