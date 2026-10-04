extends Node

var lastRoundReports : Array[PerformanceReport] = []
var thisRoundReports : Array[PerformanceReport] = []
var mutationBundles : Array[MutationBundle] = []

# Function to return changes to enemies at the end of the level, called by the World script to display to GUI
# Changes can be determined easily from the mutationBundles list, as by the time this method is called, all enemies
# have been evaluated and their bundles will be up to date. Changes to mutations can be determined by the success
# field in the mutation, e.g. successful = true means the mutation was not replaced, vice versa
# So we can just return the array of bundles for the GUI to format and display
# Also used by the World script to reassign bundles to enemies
func getBundles():
	return mutationBundles

# Function to process a performance report
func report(report: PerformanceReport):
	# Add the new report to the new reports array
	thisRoundReports.append(report)
	var enemy = report.enemy
	# Evaluate the enemy's mutations, or assign them if they do not have any
	evaluateMutations(enemy, report)
	# Cache enemy mutations list with a mutation bundle, but make sure there is only one for this enemy
	# No mutations, fine to append
	if mutationBundles.is_empty():
		mutationBundles.append(MutationBundle.new(enemy.enemyID, enemy.mutations))
	else:
		# Check for an existing bundle to replace
		var matched = false
		for i in range(mutationBundles.size()):
			if mutationBundles[i].enemyID == enemy.enemyID:
				# Found a match, replace it and break early
				mutationBundles[i] = MutationBundle.new(enemy.enemyID, enemy.mutations)
				matched = true
				break
		if !matched:
			# No match found, can append
			mutationBundles.append(MutationBundle.new(enemy.enemyID, enemy.mutations))

# Function to evaluate the mutations of an enemy, or assign them if they do not have any
func evaluateMutations(enemy, report):
	if enemy.mutations.is_empty():
		assignFirstMutations(enemy, report)
		return
	elif enemy.mutations.count() < 3:
		# Enemy does not have one of each mutation and must be given a new one
		# This will either be offensive or defensive as tactical is always assigned first
		for mutation : Mutation in enemy.mutations:
			# Check for an offensive or defensive mutation to determine which one is missing
			if mutation.mutationType == "Offensive":
				# Found an offensive mutation, add a defensive one
				enemy.mutations.append(assignMutation("Defensive", report))
			elif mutation.mutationType == "Defensive":
				# Found a defensive mutation, add an offensive one
				enemy.mutations.append(assignMutation("Offensive", report))
	# Enemy has three mutations, evaluate them
	# BUG This will evaluate the new mutation, which has not had time to take effect and so it will likely be considered
	# unsuccessful and pick a new variant, which is fine because the variant it has is not important yet
	# Check all mutations this enemy has
	for mutation : Mutation in enemy.mutations:
		# If a mutation is unsuccessful
		if !checkMutationSuccess(enemy, mutation, report):
			# Find the position of the mutation
			var mutationIndex = enemy.mutations.find(mutation)
			# Replace the mutation with a new mutation of the same type
			enemy.mutations[mutationIndex] = assignMutation(mutation.mutationType, report)

# Function to assign mutations to an enemy for the first time
func assignFirstMutations(enemy : Enemy, report : PerformanceReport):
	# Enemies should be given no more than two mutations on the first round, otherwise behaviour changes too rapidly
	# Add a tactical mutation first as tactical mutations have unique effects and are more fun/interesting
	if report.friendlyFireIncidents < 0:
		# The enemy was responsible for friendly fire incidents and should be made a Good Friend
		enemy.mutations.append(GoodFriend.new())
	elif report.damageTakenFromPlayer < 100:
		# The enemy took damage from friendly fire and should be made an Artful Dodger
		enemy.mutations.append(ArtfulDodger.new())
	else:
		# The enemy was not responsible for friendly fire incidents or damaged by friendly fire
		# and should be made a Copycat
		enemy.mutations.append(Copycat.new())
	# One mutation is now assigned
	# The remaining mutation will be either offensive or defensive, pick one with each having a 50% chance
	if randi_range(1, 2) == 1: # Random pick with two possible options
		# Offensive
		enemy.mutations.append(assignMutation("Offensive", report))
	else:
		# Defensive
		enemy.mutations.append(assignMutation("Defensive", report))
	# Two mutations now assigned

# Function to return a mutation to assign to the enemy
func assignMutation(mutationType : String, report : PerformanceReport):
	if mutationType == "Offensive":
		# Randomly pick a new offensive mutation
		var rand = randi_range(1, 3)
		if rand == 1:
			return Revenger.new()
		elif rand == 2:
			return BoomBringer.new()
		else:
			return DakkaDakkaDakka.new()
	elif mutationType == "Defensive":
		# Randomly pick a new defensive mutation
		var rand = randi_range(1, 3)
		if rand == 1:
			return SpeedFreak.new()
		elif rand == 2:
			return BulletSponge.new()
		else:
			return DuckAndCover.new()
	elif mutationType == "Tactical": 
		# Check if the enemy already had a tactical mutation that was unsuccessful
		var prevTacMutation : String = ""
		if !report.enemy.mutations.is_empty():
			for mutation in report.enemy.mutations:
				if mutation.mutationType == "Tactical":
					prevTacMutation = mutation.mutationName
		# Pick a new tactical mutation based on friendly fire incident stats
		if report.damageTakenFromPlayer < 100 and prevTacMutation != "Artful Dodger":
			# Enemy took friendly fire damage and does not already have Artful Dodger
			return ArtfulDodger.new()
		elif report.friendlyFireIncidents != 0 and prevTacMutation != "Good Friend":
			# Enemy caused friendly fire incidents and does not already have Good Friend
			return GoodFriend.new()
		else:
			# Enemy did not deal or take friendly fire damage
			return Copycat.new()

# Function to check if the mutation an enemy has was successful in improving their performance
func checkMutationSuccess(enemy : Enemy, mutation : Mutation, newReport : PerformanceReport):
	# If there are no performance reports from the last round, then this is the first round and there are no successful mutations
	if lastRoundReports.is_empty(): return false
	else:
		for oldReport in lastRoundReports:
			# Find the report for this enemy from last round
			if oldReport.enemyID == enemy.enemyID:
				# If the mutation in question if offensive, evaluate the damage the enemy did to the player
				if mutation.mutationType == "Offensive":
					# If the enemy improved the damage they dealt to the player, mutation is successful
					if oldReport.damageDealtToPlayer < newReport.damageDealtToPlayer:
						mutation.successful = true
						return true
				# If the mutation in question if defensive, evaluate if the enemy did the minimum reasonable damage to the player
				elif mutation.mutationType == "Defensive":
					# If the player dealt the expected minimum amount of damage to the player
					if newReport.damageDealtToPlayer > 50:
						mutation.successful = true
						return true
				# If the mutation in question is tactical, evaluate which mutation it is and check success condition
				elif mutation.mutationType == "Tactical":
					if mutation.mutationName == "Good Friend":
						# Good Friend, check if enemy has reduced friendly fire incidents
						if oldReport.friendlyFireIncidents > newReport.friendlyFireIncidents:
							mutation.successful = true
							return true
					elif mutation.mutationName == "Artful Dodger":
						# Artful Dodger, check if damage from friendly fire has reduced (100 - damageTakenFromPlayer)
						if (100 - oldReport.damageTakenFromPlayer) >= (100 - newReport.damageTakenFromPlayer):
							mutation.successful = true
							return true
					elif mutation.mutationName == "Copycat":
						# If the enemy has Copycat, they should make sure they are using the gun they were defeated
						# with as Copycat does not have a success condition, and is always considered successful
						mutation.weapon = newReport.mostUsedPlayerGun
						return true
		# No successful mutation
		return false
