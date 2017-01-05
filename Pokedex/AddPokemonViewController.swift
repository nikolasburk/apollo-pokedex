//
//  AddPokemonViewController.swift
//  Pokedex
//
//  Created by Nikolas Burk on 04/01/17.
//  Copyright © 2017 Nikolas Burk. All rights reserved.
//

import UIKit

class AddPokemonViewController: UIViewController {
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var imageURLTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var trainer: TrainerQuery.Data.Trainer?
  
  var newPokemonAdded: ((PokemonDetails) -> ())?
  
  
  // MARK: View Controller Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
  // MARK: Actions
  
  @IBAction func saveButtonPressed() {
    
    guard let name = nameTextField.text, nameTextField.text!.characters.count > 0,
      let url = imageURLTextField.text, imageURLTextField.text!.characters.count > 0,
      let trainerId = trainer?.id else {
        print(#function, "ERROR: No data provided")
        return
    }
    
    activityIndicator.startAnimating()

    let createPokemonMutation = CreatePokemonMutation(name: name, url: url, trainerId: trainerId)
    apollo.perform(mutation: createPokemonMutation) { [unowned self] result, error in
      self.activityIndicator.stopAnimating()
      if let error = error {
        print(#function, "ERROR: Adding new Pokemon failed (\(error.localizedDescription))")
      }
      else if let newPokemonDetails = result?.data?.createPokemon?.fragments.pokemonDetails {
        self.newPokemonAdded?(newPokemonDetails)
        self.presentingViewController?.dismiss(animated: true)
      }
    }
    
  }
  
  @IBAction func cancelButtonPressed() {
    presentingViewController?.dismiss(animated: true)
  }
  
}
