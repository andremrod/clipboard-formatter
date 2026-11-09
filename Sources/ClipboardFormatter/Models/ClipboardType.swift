enum ClipboardType: String, Sendable {
    case json
    case jwt
    case uuid
    case xml
    case base64
    case color
    case dateTime
    case cpf
    case cnpj
    case cep
    case phone
    case pixKey
    case currency
    case email
    case url
    case plainText

    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .jwt: return "JWT"
        case .uuid: return "UUID"
        case .xml: return "XML"
        case .base64: return "Base64"
        case .color: return "Cor"
        case .dateTime: return "Data/hora"
        case .cpf: return "CPF"
        case .cnpj: return "CNPJ"
        case .cep: return "CEP"
        case .phone: return "Telefone"
        case .pixKey: return "Chave PIX"
        case .currency: return "Valor (R$)"
        case .email: return "E-mail"
        case .url: return "URL"
        case .plainText: return "Texto"
        }
    }
}
