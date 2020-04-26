//
//  MenuTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 10/05/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class MenuTVC: UITableViewController
{
	var genIndex = 0
	var allPokemon = [Pokemon]()
	var currentHunts = [Hunt]()
	let textResolver = TextResolver()
	var pokemonService: PokemonService!
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var currentHuntService = CurrentHuntService()
	var huntStateService = HuntStateService()

	@IBOutlet weak var settingsButton: UIBarButtonItem!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		hideBackButton()

		tableView.separatorColor = colorService.getSecondaryColor()

		allPokemon = pokemonService.getAll()

		currentHunts = currentHuntService.getAll()
		
		showNavigationBar()

		setNavigationControllerColor()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		currentHunts = currentHuntService.getAll()
		
		setTableViewBackgroundColor()
		
		tableView.reloadData()
		
		setUpBackButton()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
	}
	
	fileprivate func hideBackButton()
	{
		navigationItem.hidesBackButton = true
	}
	
	fileprivate func showNavigationBar()
	{
		navigationController?.isNavigationBarHidden = false
	}
	
	fileprivate func setNavigationControllerColor()
	{
		navigationController?.navigationBar.barTintColor = colorService.getSecondaryColor()
	}
	
	fileprivate func setNavigationBarFont()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getXxLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func setSettingsIconColor()
	{
		settingsButton.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func setTableViewBackgroundColor()
	{
		tableView.backgroundColor = colorService.getSecondaryColor()
	}

	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		
		navigationItem.backBarButtonItem = backButton
		
		navigationController?.navigationBar.tintColor = colorService.getTertiaryColor()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 8
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 160.0;
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		genIndex = indexPath.row
		if genIndex == 7
		{
			performSegue(withIdentifier: "currentHuntSegue", sender: self)
		}
		else
		{
			performSegue(withIdentifier: "pokedexSegue", sender: self)
		}
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
		
		let showCurrentHuntImage = indexPath.row == 7 && !currentHunts.isEmpty
		
		cell.generationLabel.textColor = colorService.getTertiaryColor()
		
		if showCurrentHuntImage
		{
			cell.generationImage.image = currentHunts[0].pokemon[0].shinyImage
		}
		else
		{
			cell.generationImage.image = resolveGenImage(gen: indexPath.row)
		}
		
		cell.generationLabel.text = textResolver.resolveGenTitle(gen: indexPath.row)
		cell.generationLabel.font = fontSettingsService.getXxLargeFont()
		
		return cell
	}
	
	fileprivate func resolveGenImage(gen : Int) -> UIImage
	{
		if gen == 0
		{
			return UIImage(named: "gen1")!
		}
		if gen == 1
		{
			return UIImage(named: "gen2")!
		}
		if gen == 2
		{
			return UIImage(named: "gen3")!
		}
		if gen == 3
		{
			return UIImage(named: "gen4")!
		}
		if gen == 4
		{
			return UIImage(named: "gen5")!
		}
		if gen == 5
		{
			return UIImage(named: "gen6")!
		}
		if gen == 6
		{
			return UIImage(named: "gen7")!
		}
		if gen == 7
		{
			return UIImage(named: "shiny-charm")!
		}
		return UIImage(named: "gen1")!
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if genIndex == 7
		{
			let destVC = segue.destination as? CurrentHuntTVC

			setCurrentHuntRepositories(currentHuntTVC: destVC!)
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
		else if genIndex == 8
		{
			let destVC = segue.destination as? SettingsVC
			
			destVC?.huntStateService = huntStateService
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
		else
		{
			let destVC = segue.destination as? PokedexTVC
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
			setPokedexRepositories(pokedexTVC: destVC!)
		}
	}
	
	fileprivate func setCurrentHuntRepositories(currentHuntTVC: CurrentHuntTVC)
	{
		currentHuntTVC.pokemonService = pokemonService
		currentHuntTVC.huntStateService = huntStateService
		currentHuntTVC.currentHuntService = currentHuntService
		currentHuntTVC.currentHunts = currentHunts
		currentHuntTVC.allPokemon = allPokemon
	}
	
	fileprivate func setPokedexRepositories(pokedexTVC: PokedexTVC)
	{
		pokedexTVC.generation = genIndex
		pokedexTVC.pokemonService = pokemonService
		pokedexTVC.currentHuntService = currentHuntService
		pokedexTVC.huntStateService = huntStateService
		pokedexTVC.currentHunts = currentHunts
	}
	
	@IBAction func settingsPressed(_ sender: Any)
	{
		genIndex = 8
		performSegue(withIdentifier: "settingsSegue", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService.getPrimaryColor()
		cell.layer.cornerRadius = 30
	}
}
