import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func triggerAlert(result: AlertModel){
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ){ [weak self] _ in
            guard let self else { return }
            self.delegate?.playAgain()
        }
        alert.addAction(action)
        
        delegate?.presentAlert(alert: alert)
    } 
}
