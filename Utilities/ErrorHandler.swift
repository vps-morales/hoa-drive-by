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
        alert("Error", isPresented: $errorHandler.isShowingError) {
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
            if let error = errorHandler.currentError {
                let title = error.errorDescription ?? "An error occurred"
                let suggestion = error.recoverySuggestion ?? ""
                let message = suggestion.isEmpty ? title : "\(title)\n\n\(suggestion)"
                return Text(message)
            }
            return Text("An unknown error occurred")
        }
    }
}
