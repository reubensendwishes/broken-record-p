export type AuthField<T = string> = {
    id: T
    type: string
    label: string
    helper?: string
    maxLength?: number
}

export type AuthFields<T = string> = [AuthField<T>, ...AuthField<T>[]]

export type Validator = (value: string) => string | Promise<string>

export type Validators<T extends string = string> = Record<T, Validator>

export type FabItem<T = string> = {
    name: T
}

export type FabItems<T = string> = [FabItem<T>, ...FabItem<T>[]]
