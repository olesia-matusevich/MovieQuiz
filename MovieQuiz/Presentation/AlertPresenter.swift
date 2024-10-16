import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func triggerAlert(result: AlertModel){
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default){ [weak self] _ in // слабая ссылка на self
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.delegate?.playAgain()
        }
        alert.addAction(action)
        
        delegate?.presentAlert(alert: alert)
    } 
}
