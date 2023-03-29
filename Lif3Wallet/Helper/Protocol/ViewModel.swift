//
//  ApiProtocol.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/22/22.
//

import Foundation

protocol ViewModel {
    var isBusy:Bool { get set }
    var error: Error? { get set }
}
