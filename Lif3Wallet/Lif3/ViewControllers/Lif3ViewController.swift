//
//  Lif3ViewController.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 1/16/23.
//

import UIKit

protocol lifeViewControllerDelegate {
     func didTapSwapTokens()
    func didTapGarden()
    func didTapFountainOfLif3()
    func didTapTerrace()
    func didTapGreenHouse()
    func didTapNursery()
}

class Lif3ViewController: UIViewController {
    
    // MARK: - Contants
    static func instantiate() -> Lif3ViewController {
        let controllerStr = String(describing: Lif3ViewController.self)
        return UIStoryboard(name: "Lif3", bundle: nil).instantiateViewController(withIdentifier: controllerStr) as! Lif3ViewController
    }
    
    @IBOutlet weak var swapTokenView: UIView! {
        didSet {
            swapTokenView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSwapToken(_:)))
            swapTokenView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var gardenView: UIView! {
        didSet {
            gardenView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapGarden(_:)))
            gardenView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var fountainView: UIView! {
        didSet {
            fountainView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFountain(_:)))
            fountainView.addGestureRecognizer(tap)
        }
    }
    
    
    @IBOutlet weak var terraceView: UIView! {
        didSet {
            terraceView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapTerrace(_:)))
            terraceView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var greenhouseView: UIView! {
        didSet {
            greenhouseView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapGreenhouse(_:)))
            greenhouseView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var nurseryView: UIView! {
        didSet {
            nurseryView.layer.cornerRadius = 10
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapNursery(_:)))
            nurseryView.addGestureRecognizer(tap)
        }
    }
    
    var delegate:lifeViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @objc func tapSwapToken(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapSwapTokens()
    }
    @objc func tapGarden(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapGarden()
    }
    @objc func tapFountain(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapFountainOfLif3()
    }
    @objc func tapTerrace(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapTerrace()
    }
    @objc func tapGreenhouse(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapGreenHouse()
    }
    @objc func tapNursery(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapNursery()
    }
    

}
