//
//  ProbabilityService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class ProbabilityService
{
	fileprivate let lgpeProbabilityService = LGPEProbabilityService()
	fileprivate let gen8ProbabilityService = Gen8ProbabilityService()
	fileprivate let masudaProbabilityService = MasudaProbabilityService()

	func getProbability(_ generation: Int, _ isCharmActive: Bool, _ isLureInUse: Bool, _ isMasudaHunting: Bool, _ encounters: Int, _ shinyOdds: Int) -> Double
	{
		if isMasudaHunting
		{
			return masudaProbabilityService.getProbability(eggsHatched: encounters, odds: shinyOdds)
		}
		if generation == 5
		{
			return gen8ProbabilityService.getProbability(battles: encounters, isCharmActive: isCharmActive)
		}
		else if generation == 6
		{
			return lgpeProbabilityService.getProbability(combo: encounters, isCharmActive: isCharmActive, isLureInUse: isLureInUse)
		}
		return Double.getProbability(encounters: encounters, odds: shinyOdds)
	}

	func getProbabilityText(encounters: Int, shinyOdds: Int, probability: Double) -> String
	{
		let huntIsOverOdds = encounters > shinyOdds

		if huntIsOverOdds
		{
			return " Hunt has gone over odds."
		}
		else
		{
			let formattedProbability = String(format: "%.2f", probability)
			return " Probability is \(formattedProbability)%"
		}
	}
}
