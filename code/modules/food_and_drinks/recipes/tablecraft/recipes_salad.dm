
// see code/module/crafting/table.dm

////////////////////////////////////////////////SALADS////////////////////////////////////////////////

/datum/crafting_recipe/food/herbsalad
	name = "Herb salad"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/herbsalad
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/aesirsalad
	name = "Aesir salad"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus = 3,
		/obj/item/reagent_containers/food/snacks/grown/apple/gold = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/aesirsalad
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/validsalad
	name = "Full salad"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/validsalad
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/oatmeal
	name = "Oatmeal"
	reqs = list(
		/datum/reagent/consumable/milk = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/oat = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/oatmeal
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/fruitsalad
	name = "Fruit salad"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/reagent_containers/food/snacks/grown/grapes = 1,
		/obj/item/reagent_containers/food/snacks/watermelonslice = 2

	)
	result = /obj/item/reagent_containers/food/snacks/salad/fruit
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/junglesalad
	name = "Jungle salad"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/reagent_containers/food/snacks/grown/grapes = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 2,
		/obj/item/reagent_containers/food/snacks/watermelonslice = 2

	)
	result = /obj/item/reagent_containers/food/snacks/salad/jungle
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/citrusdelight
	name = "Citrus delight"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1

	)
	result = /obj/item/reagent_containers/food/snacks/salad/citrusdelight
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/edensalad
	name = "Salad of Eden"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl =1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia = 1,
		/obj/item/reagent_containers/food/snacks/grown/peace = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/edensalad
	subcategory = CAT_SALAD
