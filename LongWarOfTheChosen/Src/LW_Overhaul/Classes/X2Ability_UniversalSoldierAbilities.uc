//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_UniversalSoldierAbilities.uc
//  AUTHOR:  Grobobobo
//  PURPOSE: Defines shared abilities that are available on all XCOM soldiers
//---------------------------------------------------------------------------------------

class X2Ability_UniversalSoldierAbilities extends X2Ability config (LW_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	`LWTrace("  >> X2Ability_PerkPackAbilitySet.UniversalSoldierAbilities()");
	Templates.AddItem(CreateHeavyRevive());
	Templates.AddItem(CreateStockStrike());
	Templates.AddItem(CreateGetUp());
	return Templates;
}

static function X2AbilityTemplate CreateHeavyRevive()
{
	local X2AbilityTemplate				Template;
	local X2Condition_UnitProperty		TargetCondition;
	local X2Condition_UnitEffects		EffectsCondition;
	local X2Effect_RemoveEffects		RemoveEffects;
	local X2Effect_Persistent			DisorientedEffect;
	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2Condition_UnitEffects		ExcludeEffects;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HeavyRevive');

	Template.AbilitySourceName = 'eAbilitySource_Commander';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_chosenrevive";
	Template.DisplayTargetHitChance = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MUST_RELOAD_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter Condition
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Target Condition
	Template.AbilityTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = class 'X2Ability_DefaultAbilitySet'.default.REVIVE_RANGE_UNITS;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// Cannot target units being carried.
	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddRequireEffect(class'X2StatusEffects_LW'.default.HeavyDazedName, 'AA_MissingRequiredEffect');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects_LW'.default.HeavyDazedName);
	Template.AddTargetEffect(RemoveEffects);

	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect(class'X2AbilityTemplateManager'.default.DisorientedName, 'AA_UnitIsDisoriented');
	ExcludeEffects.AddExcludeEffect(class'X2StatusEffects'.default.BurningName, 'AA_UnitIsBurning');
	Template.AbilityShooterConditions.AddItem(ExcludeEffects);

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(, , false);
	DisorientedEffect.bRemoveWhenSourceDies = false;
	DisorientedEffect.ApplyChance = class'X2Ability_DefaultAbilitySet'.default.REVIVE_DISORIENT_PERCENT_CHANCE;
	Template.AddTargetEffect(DisorientedEffect);

	Template.ActivationSpeech = 'HealingAlly';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowPostActivation = true;
//BEGIN AUTOGENERATED CODE: Template Overrides 'Revive'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CustomFireAnim = 'HL_Revive';
//END AUTOGENERATED CODE: Template Overrides 'Revive'

	return Template;
}

static function X2AbilityTemplate CreateStockStrike()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2Condition_UnitProperty				AdjacencyCondition;	
	local X2Condition_TargetHasOneOfTheEffects	NeedOneOfTheEffects;
	local X2Effect_Stunned						StunnedEffect;
	local array<name> SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MC_Stock_Strike');

	Template.AbilitySourceName = 'eAbilitySource_Commander';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_coupdegrace";
	Template.DisplayTargetHitChance = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MUST_RELOAD_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SimpleSingleMeleeTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	NeedOneOfTheEffects=new class'X2Condition_TargetHasOneOfTheEffects';
	NeedOneOfTheEffects.EffectNames.AddItem(class'X2Effect_MindControl'.default.EffectName);
	Template.AbilityTargetConditions.AddItem(NeedOneOfTheEffects);

	// Target Conditions
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	AdjacencyCondition = new class'X2Condition_UnitProperty';
	AdjacencyCondition.RequireWithinRange = true;
	AdjacencyCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	AdjacencyCondition.TreatMindControlledSquadmateAsHostile = true;
	Template.AbilityTargetConditions.AddItem(AdjacencyCondition);

	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName); //okay when disoriented
	Template.AddShooterEffectExclusions(SkipExclusions);
	
	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false);
	Template.AddTargetEffect(StunnedEffect);
	
	Template.CustomFireAnim = 'FF_Melee';

	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;

	return Template;
}

static function X2AbilityTemplate CreateGetUp()
{
	local X2AbilityTemplate				Template;
	local X2Condition_UnitProperty		TargetCondition;
	local X2Condition_UnitEffects		EffectsCondition;
	local X2Effect_RemoveEffects		RemoveEffects;
	local X2Effect_Persistent			DisorientedEffect;
	local X2AbilityCost_ActionPoints	ActionPointCost;
	local array<name> SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GetUp');

	Template.AbilitySourceName = 'eAbilitySource_Commander';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_chosenrevive";
	Template.DisplayTargetHitChance = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MUST_RELOAD_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter Condition
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeCivilian=true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = class 'X2Ability_DefaultAbilitySet'.default.REVIVE_RANGE_UNITS;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddRequireEffect(class'X2StatusEffects'.default.UnconsciousName, 'AA_MissingRequiredEffect');
	EffectsCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.BeingCarriedEffectName, 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);
	Template.AddTargetEffect(RemoveEffects);

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(, , false);
	DisorientedEffect.bRemoveWhenSourceDies = false;
	DisorientedEffect.ApplyChance = class'X2Ability_DefaultAbilitySet'.default.REVIVE_DISORIENT_PERCENT_CHANCE;
	Template.AddTargetEffect(DisorientedEffect);

	Template.ActivationSpeech = 'HealingAlly';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowPostActivation = true;
//BEGIN AUTOGENERATED CODE: Template Overrides 'Revive'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CustomFireAnim = 'HL_Revive';
//END AUTOGENERATED CODE: Template Overrides 'Revive'

	return Template;
}
