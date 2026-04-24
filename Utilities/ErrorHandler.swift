import SwiftUI

class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var isShowingError = false

    func handle(_ error: Error) {
        let appError = AppError.from(error)
        currentError = appError
        isShowingError = true
    }

    func handle(_ appError: AppError) {
        currentError = appError
        isShowingError = true
    }

    func clear() {
        currentError = nil
        isShowingError = false
    }
}

extension View {
    func errorAlert(errorHandler: ErrorHandler) -> some View {
        let isShowing = Binding(
            get: { errorHandler.isShowingError },
            set: { errorHandler.isShowingError = $0 }
        )

        let messageText: String = {
            if let error = errorHandler.currentError {
                let title = error.errorDescription ?? "An error occurred"
                let suggestion = error.recoverySuggestion ?? ""
                return suggestion.isEmpty ? title : "\(title)\n\n\(suggestion)"
            }
            return "An unknown error occurred"
        }()

        return alert("Error", isPresented: isShowing) {
            if let error = errorHandler.currentError, error.isRecoverable {
                Button("OK", role: .cancel) {
                    errorHandler.clear()
                }
            } else {
                Button("OK", role: .destructive) {
                    errorHandler.clear()
                }
            }
        } message: {
            Text(messageText)
        }
    }
}
