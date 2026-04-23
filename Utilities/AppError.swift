import Foundation

enum AppError: LocalizedError {
    case fileNotFound
    case invalidData
    case decodingFailed(String)
    case encodingFailed(String)
    case imageSaveFailed
    case imageLoadFailed
    case communityNotFound
    case propertyNotFound
    case violationNotFound
    case bootstrapFailed(String)
    case saveFailed(String)
    case loadFailed(String)
    case invalidInput(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .invalidData:
            return "Invalid data format"
        case .decodingFailed(let details):
            return "Failed to load data: \(details)"
        case .encodingFailed(let details):
            return "Failed to save data: \(details)"
        case .imageSaveFailed:
            return "Could not save image"
        case .imageLoadFailed:
            return "Could not load image"
        case .communityNotFound:
            return "Community not found"
        case .propertyNotFound:
            return "Property not found"
        case .violationNotFound:
            return "Violation not found"
        case .bootstrapFailed(let details):
            return "Failed to initialize app: \(details)"
        case .saveFailed(let details):
            return "Failed to save: \(details)"
        case .loadFailed(let details):
            return "Failed to load: \(details)"
        case .invalidInput(let message):
            return message
        case .unknown(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "The app will create a new file when you save data."
        case .invalidData:
            return "Try closing and reopening the app."
        case .decodingFailed:
            return "Your data may be corrupted. Try restarting the app."
        case .encodingFailed:
            return "Check if your device has enough storage space."
        case .imageSaveFailed:
            return "Check if your device has enough storage space. Try using a smaller image."
        case .imageLoadFailed:
            return "The image file may have been deleted. Try re-adding the photo."
        case .communityNotFound:
            return "Make sure the community exists. Try refreshing the app."
        case .propertyNotFound:
            return "Make sure the property exists in the selected community."
        case .violationNotFound:
            return "The violation may have been deleted."
        case .bootstrapFailed:
            return "Try restarting the app. If the problem persists, reinstall HOA Drive-By."
        case .saveFailed:
            return "Check your device storage and try again."
        case .loadFailed:
            return "Try restarting the app."
        case .invalidInput(let message):
            return message.contains("required") ? "Please fill in all required fields." : nil
        case .unknown:
            return "Try closing and reopening the app."
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .bootstrapFailed:
            return false
        default:
            return true
        }
    }
}

extension AppError {
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        let nsError = error as NSError
        switch nsError.domain {
        case NSCocoaErrorDomain:
            if nsError.code == NSFileReadNoSuchFileError {
                return .fileNotFound
            }
            return .loadFailed(error.localizedDescription)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
