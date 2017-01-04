//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Nikolas Burk on 03/01/17.
//  Copyright © 2017 Nikolas Burk. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PokemonCell: UITableViewCell {
  
  @IBOutlet weak var pokemonImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  var request: DataRequest?
  
  var pokemonDetails: PokemonDetails? {
    didSet {
      updateUI()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    pokemonImageView.image = nil
    request?.cancel()
  }
  
  func updateUI() {
    if let name = pokemonDetails?.name {
      nameLabel.text = name
    }
    loadImage()
  }
  
  func loadImage() {
    if let pokemonURL = pokemonDetails?.url {
      request = Alamofire.request(pokemonURL).responseImage { response in
        if let image = response.result.value {
          self.pokemonImageView.image = image
        }
      }
    }
    else {
      print(#function, "ERROR: No URL for \(pokemonDetails?.name)")
    }
  }
  
}

