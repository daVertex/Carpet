-- =================================
-- SERVICES
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- =================================
-- PLAYER / WORLD
-- =================================
local player = Players.LocalPlayer
local mine = workspace:WaitForChild("Mine")

-- =================================
-- HC REMOTE (auto supports RemoteEvent/RemoteFunction)
-- =================================
local HCRemote = ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("ItemAbilityRemotes")
	:WaitForChild("HollowCornucopia_Activation")

local function callHC()
	if HCRemote:IsA("RemoteEvent") then
		HCRemote:FireServer()
		return true
	elseif HCRemote:IsA("RemoteFunction") then
		HCRemote:InvokeServer()
		return true
	else
		warn("[HC] HollowCornucopia_Activation is not RemoteEvent/RemoteFunction. It is:", HCRemote.ClassName)
		return false
	end
end

-- =================================
-- NAME VARIANTS (robust matching)
-- - raw lowercase
-- - stripped (removes non-alnum/_)
-- =================================
local function variants(s: string)
	s = string.lower(s or "")
	local stripped = string.gsub(s, "[^%w]", "")
	return s, stripped
end

-- =================================
-- IONIZED ATTRIBUTE CHECK
-- Supports:
--   ore:GetAttribute("variantType") == "ionized"   
--   ore:GetAttribute("Ionized") == true / "ionized" (optional support)
-- Works for BasePart or Model (checks model + primary/first part)
-- =================================
local function isIonizedOre(obj)
	local function readAttr(o)
		if not o or typeof(o.GetAttribute) ~= "function" then return nil end

		local vt = o:GetAttribute("variantType")
		if vt ~= nil then return vt end

		return o:GetAttribute("Ionized")
	end

	local v = readAttr(obj)

	
	if v == nil and obj and obj:IsA("Model") then
		v = readAttr(obj.PrimaryPart)
		if v == nil then
			local part = obj:FindFirstChildWhichIsA("BasePart", true)
			v = readAttr(part)
		end
	end

	if v == nil then return false end
	if type(v) == "boolean" then return v end
	if type(v) == "string" then return string.lower(v) == "ionized" end
	return false
end

-- =================================
-- ORE TABLES (all lowercase)
-- =================================
local ORE_TABLES = {}

-- ============ W1 Gear ============
-- Cyber R (default)
ORE_TABLES.default = {
	"cybernetium",
	"cryotic",
	"nuummite",
	"elysian",
	"tanzanite",
	"lavendulan",

	"__IONIZED__",
	"hemimorphite",

	"bluesteel",
	"cobalt",
	"turquenite",
}



-- Lucy L
ORE_TABLES.lucy = {
	"lucidium","vitrilyx","temporum","neptunium","teslarium","lanthanite","rusticog","eluryan",
	"alexandrite","glaucodot","patronite","black diamond","antimony","osmium","musgravite",
	"schizolite","chroma contaris","cuspidine",
}

-- Polar T
ORE_TABLES.polar_t = {
	"polarium","quandrium","animyl","spatializine","opal","quenselite","aegirine","albite","howlite","lead",
}

-- C Candle
ORE_TABLES.c_candle = {
	"candilium","elegascene","bonfire","flaeon","flexinite","newtonium","solarite","eluxant","zellerite",
	"pyromorphite","tsavorite","simbercite",
}

-- Elem T (ionized cobalt -> cobalt)
ORE_TABLES.elem_t = {
	"elementium","exoretic","azuryl","pasivium","polonium","poiseon","photoprisma","chromatite","nuummite",
	"unobtainium","__IONIZED__","cobalt","alternium","vanadinite","prismatica","elysian","elusium","rainbowite","tanzanite",
	"solid bromine","petrified wood","delectium","bluesteel","plutonium","petalite","chrysoberyl","galvanite",
	"padparadscha","amber",
}

-- Ink Orb
ORE_TABLES.ink_orb = {
	"inkonium","sentient viscera","speatrium","blazuine","monocage","inktite","viscrol","hyperstone","jet",
	"purpurite","spatializine","sugilite","quenselite","lunar jet","chrome","lead","obsidian glass",
}

-- ============ W1 Axes ============
-- Cry P
ORE_TABLES.cry_p = {
	"vitrilyx","scertanium","aesthetitum","alternium","vanadinite","opal","lazulite","solid bromine","antimony",
	"phlogopite","galvanite",
}

-- Trin C
ORE_TABLES.trin_c = {
	"trinitium","poiseon","flaeon","freon","seraphrite","theiograph","intoxium","coldifrium","incinderium",
	"pyrite","ametrine","chalcedony","magnesium","yvonite","bismuth",
}

-- 57 Leaf
ORE_TABLES.leaf_57 = {
	"spristium","oviridis","ornalium","prasiloudis","chromatite","nocturnite","unobtainium","elusium","elysian",
	"rainbonite","elvengreen","delectium","actinolite","mica","cobalt","padparadscha","olivine",
}

-- ============ SW1 Axes ============
ORE_TABLES.nos_axe = {
	"lunar halcyon emission","unobtainium","frostical","enstatite","adurite","viridian","gilded gold",
	"sporgilian","chrysoberyl","javanite","turquoise","diamond","amber",
}

ORE_TABLES.nilaxe = {
	"orb of discontent","lunar astatine","sagittarius quasar","lutetium","inktite","hyperstone","vortenrial",
	"uldarite","chambersite","lunar jet","corroplat","chrome",
}

-- ============ SW1 Gear ============
ORE_TABLES.lut_sup = {
	"lutetium","unobtainium","lunar newtonium","lunar cryotic","lunar jet","lumbonium","ocean jasper",
}

ORE_TABLES.lemon = {
	"lunar freon","calite","lunar promethium","citrine","turquoise",
}

ORE_TABLES.esg = {
	"electrolyx","lunar dyronsinite","electroluim","cerrusite","lunar zefendium","sapphire",
}

ORE_TABLES.vwv = {
	"vaporwave pulsar","lunar poiseon","adurite","leryium","corroplat","thorium",
}

ORE_TABLES.sssw = {
	"soundstrocity","lunar codex","hyperstone","deathinium","edmium","corrodine","diamond",
}

ORE_TABLES.tpm = {
	"lunar aurora","lunar neomandelite","lunar promethium","chambersite","turquoise","ocean jasper",
}

-- Amb S (ionized olivine -> olivine)
ORE_TABLES.amb_s = {
	"lunar aether","lunar Ω","lunar trinitium","scarfyte","aether","ambrosia","sagittarius quasar",
	"lunar halcyon emission","lunar dyronsinite","seraphrite","viverra","divinessence","__IONIZED__","olivine","theiograph",
	"alexandrite","gilded gold","leryium","lunar cryotic","pyrite","ametrine","javanite","ancient bronze","bismuth",
}

ORE_TABLES.ill_ill = {
	"illuminyx","protoflare","surgium","astatine","lunar freon","lutetium","prasiloudis","unobtainium","actinium",
	"lunar newtonium","promethium","elvengreen","vitridian","lunar zefendium","lunar galaxite","reflectix",
	"actinolite","vegentium","uranium","wavellite","lumbonium","jaxite","sapphire",
}

ORE_TABLES.rgb_c4 = {
	"rgb pulsar","glacielle","electrolyx","lunar malachite","snoblintium","lunar flaeon","lunar poiseon","exolite",
	"nocturnite","zefendium","electroluim","ultranium","cerrusite","coldifrium","painite","sporgilian","radium",
}

-- ============ W2 Axes ============
ORE_TABLES.moon_s = {
	"contravexium","circeterra","optimivium","entiniol","cometryx","divinushield","calite","shimmersite","lecilux",
	"sodium","voliumina","scapolite","aurutine",
}

ORE_TABLES.soul_s = {
	"spiritian","andromidium","laivertine","crystal oculite","the nightmare","the dream","vexerite","mycerian",
	"aquatic vortex","ridailte","exoflame","luminaweb","xenon","benitoite","aquintite","azurite","heidalium",
	"shroomite","apatite","lepidolite","cyprine",
}

-- POC (ionized removed)
ORE_TABLES.poc = {
	"neomandelite","celestivian","icarus","twilight mist","plasmonium","hexagelite","cosmic treasure","kaleidium",
	"enchantium","accretite","voidflower","__IONIZED__","rosaraldyx","matterium","__IONIZED__","arctic crystal","quadratus","fracidial",
	"nitoril","chromavitrite","coldstorm","plasmal","ignacaelum","auroralium","violixium","cestilade","__IONIZED__","powder snow",
	"zenflow","tealine","culindrene","messier 92","pleskite","phendium","plerivium","blue giant","eboxylite",
	"epidote","amazonite","protoplanetary disk","diopside","radisol","ekanite","andesine",
}

-- ============ W2 Gear ============
ORE_TABLES.shat_h = {
	"heart of the frosted","hexagelite","aquatic vortex","condensium","pleskite","aquintite",
}

ORE_TABLES.spiral = {
	"galactic rupture","ignacaelum","rosaraldyx","cinnabar","protoplanetary disk",
}

ORE_TABLES.t1_ter = {
	"noo s-sing. ti","voidflower","fracidial","mycerian","cestilade","xenon","heidalium","radisol",
}

ORE_TABLES.plas_n = {
	"plasmonium","atomium","quadratus","plasmal","versulium","amazonite","andesine",
}

ORE_TABLES.c_cb = {
	"coronal flare","aurantial","lunar flaeon","lunar coronium","lunar dyronsinite","ignisaxum","protonium",
	"quadiol","gilded gold","chrome",
}

-- VV (ionized apatite -> apatite)
ORE_TABLES.vv = {
	"vitriol","catastormite","coselnix","torilite","__IONIZED__","apatite","the dream","coldstorm","lotivium","condensium","argon",
	"citrine","shroomite","arctic crystal","cirelin","powder snow","sphalerite","chlorodyrill","oligoclase",
}

ORE_TABLES.cc = {
	"unearthly cubes","covellite","divinushield","auroralium","shimmersite","radon","benitoite","aquintite",
	"aventurine","voliumina","cyprine",
}

ORE_TABLES.oo = {
	"obliveracy endmost","stazenium","nemolite","void’s iris","cestilade","fluorite","luminaweb","illuded light",
	"xenotime","chiron","lunalistone",
}

ORE_TABLES.ss_t = {
	"gravitaticor","estrela","accretite","arcaleus","fracidial","ignisaxum","calite","protonium","quadiol",
	"rosaraldyx","cinnabar","demantoid","scapolite","chiron",
}

-- ============ SW2 Axes ============
ORE_TABLES.thun_p = {
	"solar crystal","celestial gem","galactic gem","illuminite","andromedite","equinox",
}

ORE_TABLES.yell_a = {
	"y","accerite","red beryl","electronite","tewite","vanadium",
}

ORE_TABLES.vortaxe = {
	"void eye","agsperum’s charm","thai’s star","cyclone crystal","agsper crystal","void crystal","legacy agsper crystal",
	"akabe crystal","legacy solar crystal","abyssal gem","water gem","corrupt soul matter","corrupt beryl","enigmasteri",
	"corrupt adamantium","zirconium","corrupt electronite","labradorite","corrupt shazzonite","red beryl","shazzonite",
	"tewite","pearl",
}

-- ============ SW2 Gear ============
ORE_TABLES.luck_c = {
	"legacy luck crystal","legacy solar crystal","joey crystal","pulsarite","zirconium",
}

ORE_TABLES.sgr_a = {
	"cybernix","sgr_a","pulsar crystal","anti-shadow crystal","vortex crystal","blaze crystal","solar crystal","shadow crystal",
	"celestial gem","neutronite","illuminite","aurora borealis","auxinis","anti electronite","heliotrope","anti scoria",
	"anti adeptite","equinox","anti extunium","bauxite",
}

ORE_TABLES.x2_b = {
	"x2 crystal","matterform","tycoon crystal","cryptical","protoflare","ethereal gem","void heliotrope","pulsarite",
	"void neutronite","void pearl","celestialite","pink-gold pearl",
}

-- ============ Digita A ============
ORE_TABLES.mech_a = {
	"mechaspark","conduit","gizmonium","jigmabot","manifold","factorium",
}

ORE_TABLES.cyber_d = {
	"teslarian","fluxorium","eye of the siren","triginium","electris","spinvolt","mesmegram","technetium","inceptix",
	"currentsteel","metalescent","joltyx","scrap","zapsite","lexistile","azurenet",
}

-- Cod3 B (ionized c matrix -> c matrix)
ORE_TABLES.cod3_b = {
	"m4trix","terascental","revonet","mk2 sonar","poor connection","retronium","hedron","subject.greenlight","teevox g",
	"matrixly","hypersulon","scantron","zelenite","__IONIZED__","c matrix","holographite","convexium","ram","meshtin","matrix remnant","hash",
}

ORE_TABLES.g_light = {
	"star-zero","wisticora","quantalxy","nebula nexus","chromatechnimar","mistirine","arcanium","kadabstrum","mooncharm",
	"astral processor","dreamveil","galaswirl","moonlite","meteorite","primarium","circadia","shattergleam","iris",
	"sparkletize","cassiopeia","zarasite","glowstix",
}

-- MURD-E (delta fixed; ionized removed)
ORE_TABLES.murd_e = {
	"monocritica","32-bit integer limit","novurbite","Δ","matrixalga","hiderae","speedulant","cyberillic","oscilline","limelight",
	"lunar codex","polonium","bug","__IONIZED__","noise","__IONIZED__","pyrite","kadabstrum","turnfire","zalgrain","__IONIZED__","turquoise","__IONIZED__","ad-on","stilomite","alternium",
	"gauzian","projectron","decimate","vanadinite","rgb","edmium","monoshade","banbox","vitridian","override","hackware","__IONIZED__",
	"tiers.common","vector3","inflectium","diginix","defect","plutonium","iris","matricube","black opal","gridulyx",
	"ancient bronze","nullum","math.random","jaxite",
}

-- Plas Rail (ionized removed)
ORE_TABLES.plas_rail = {
	"chicago","photon fluxulite","cosmonolithius","voltiflux","draesdruvite","star-zero","statigen","ethyrlem","valenarium",
	"auriceph","mistirine","eye of the siren","starbit","emberis","electricore","twilite","lusterene","cosmalens","cobaltax",
	"bronzeprint","shockbox","mystirune","electroball","zapsite","technetium","teevox b","nebulaize","annalyte","apparatus",
	"helipulse","magellanium","plasmaduct","plasmos","g matrix","charged box","skysight","crosswire","andrealite","heatium",
	"scrap","hexagonyl","tungsten","stromos","sophium","azurenet",
}

-- ============ Digita G ============
ORE_TABLES.laser_s = {
	"invalid apprehension","glitchreax","decimora","candeisum","weatherlite","teevox r","plasmaduct","oxidite","viralburst",
	"charged box","phosphor","tenebralite","shockpad",
}

ORE_TABLES.part_a = {
	"auriceph","shockbox","dischargium","volticoil","sparkplug","electroshock",
}

ORE_TABLES.abs_a = {
	"spherocube","geigite receptacle","candesium","oxidite","cubeponeent","exocore","weatherlite","brass",
}

ORE_TABLES.lspeed = {
	"speedulant","icosaformite","paraxenos","hyperchrome","projectron","prismata","grafivolt","zelenite","pinturillum",
	"convexium","quadricite",
}

ORE_TABLES.d_gw = {
	"holovirlux","virtulily","statigen","wireframe","matrisse","triginium","holographite","schematan","magneticore","tensegrum",
	"oscilllyx","inceptix","duscubite","virophage","indigrid","lusterene","concavium","wirefield","recursine","rhodium",
}

ORE_TABLES.decons = {
	"the firewall","hyperfullerene","darkmatter stabilizer","luridium","corruptela","lifeforce drainer","chaotica","c-ore error",
	"gravitron","corruptal","mechaspark","terraformation","endolite","rendispike","datakill","conduit","inversytle","cogchain",
	"crimsonhack","abstractum","gizmonium","lumiscript","erris","irongrip","xerror","metalescent","adasparta","parallux",
	"noise","gearlock","manifold","bulwark","interspace","factorium","lexistile","antistone",
}

ORE_TABLES.w_star = {
	"polaroidium","galaxia","portalium","cosmilite","pixelated mass","nebula tempest","vys","kensopina","bipulsidine","tetrium",
	"onian","heliotropic fracture","pinturillum","pocket galaxy","darkstar","ammolite","whipstorm","wishmore","fantaisine",
	"vibrantasia","sophium","planetarium","rhiannine","grafivolt","mauvelite","starmite","prismium","twilite","galaxite",
	"astralistone","glowstix",
}

-- ============ Aest A ============
ORE_TABLES.chris_c = {
	"dynafrost","festivian","boreas","nixalis","candy vortex","candied nocturnite","cublextirye","peppermint core","orenament",
	"giftbox","gingorebread","snowman shard","hot chocolatine","cookium","cacaolite",
}

-- ============ Aest G ============
ORE_TABLES.candy = {
	"oculatum","flamakern","hallowed cage","cucurbite","vermillion","macabris","animatether","cancornite","chocolatine","frenikyte",
}

ORE_TABLES.love_l = {
	"amare","sentimentium","passionblaze","bandeau","corazmore","velvelicacy",
}

ORE_TABLES.phan_l = {
	"petrified wood","nocturnite","coldifrium","agoraphore","jet","obsidian glass","alexandrite","plasmitan","solid bromine","chocolatine",
}

ORE_TABLES.heartb = {
	"albuca spiralis","cleoparite","lovessence","valentiyl","penumbrosia","rosarium","cordis gemma","aesthetitum","antiquite","heliostra",
	"lovelocket","amorium","enstatite","sunstone","core fragment","orpiment","box of chocolatine","serandite","rose quartz",
}

ORE_TABLES.f_frag = {
	"the north pole","glaceiaflux","behemoth snowflake","north star","glacius","noctilucite","blizzardine","crystallized solarite",
	"frostenice","sub-zero","frostarian","blizzarium","bottled snowstorm","glaciare","iciline","blue ice","crystal snow","frigite",
}

-- Parasol (ionized crimson -> crimson)
ORE_TABLES.parasol = {
	"sunflower","sunlypse","nautitan","pentaurunel","frostica","necrocrysta","victide","sunshade","clotivein","sol","agoraphore",
	"abyssium","snowsled","beachball","nixalis","mystifall","passionblaze","solar haze","jollinyte","infrapolus","cucurbite",
	"candy vortex","cublextirye","peppernite","compact snow","breezeflow","vermillion","incandescine","peppermist","bandeau",
	"peppermint core","kahakaimar","corazmore","fizzyglass","orenament","snowball","pinappore","tannimbar","clawvern","starrine",
	"cadaverite","teslacane","spiravix","animatether","splashium","popsiclice","cancornite","velvelicacy","__IONIZED__","crimson","vantaglass",
	"snowman shard","bitumite","hot cacaoite","solaurum","raydelium","frostnip","chocolatine","hydroclase","fernium","lost soul",
	"scoria","hallowite","cookium","frenikyte","literolite","siltstone",
}

-- Type S (ionized removed)
ORE_TABLES.type_s = {
	"umbrasnare","aphantasia","praefectus","silverthorn","bloodshot","eyemalgam","nightwatcher","soulshatter","ghostdeerium",
	"doomsekkar","pyrinal","clouded opal","cytogoo","mavreline","lumilite","imniswirl","shadowsnap","whispurr","goo","scaramost",
}

-- ============ Luce A ============
-- Shim S (ionized removed)
ORE_TABLES.shim_s = {
	"polaris","cryonstelar","algifica","glacielle","froidure","glacial monolith","chandelabra","north star","frostica","nauticalis",
	"aesrith","gelisol","kindleflame","luna","boreas","freon","winterlark","kokkinip","twinkle star","stockingstone","dulumino",
	"astralisium","nocturnite","nivaorum","cublextirye","compact snow","starseeker","polarnorth","kelvine","tinsel","frigite",
	"asterixia","blizzauril","orenament","snowball","grandidierite","druzurite","cryoclase","adventite","afghanite","gingorebread",
	"twiline","lefkollent","refractice","ice fragment","cryolux","naviwrap","yvonite","cookium","glitterine","cubice",
}

-- ============ Luce G ============
-- Reaper (ionized removed)
ORE_TABLES.reaper = {
	"keres","praecantatus","maplefall","morichronica","hollowed","corerupted","vlasovale","harvest moon","venubrite","clementium",
	"ritualisium","wraith","smile","leaffall","tombstone","contemptus gemma","bonium","candy bucket","memoramber","darkseed","darkfeeb",
	"gup","vitiscus[]","sweetcore","veloveil","eidyl","dandedinkle","serratium","shacklevoid","firelite","cultistone","floral bromine",
	"limeslime","flickerfall","flesh","scaramost","flickerfright","illusionite","brimstone","dripwood","soulgum","spooky chocolatine",
}

-- BoSW (ignore spectral; ionized removed)
ORE_TABLES.bosw = {
	"sacrilege","it.","the sludge","contemptus gemma","moon fragment","soulswirl","whirlwisp","sigilite","phantomite","vanpirite",
	"magician","lucifite","hexaburst","weesp","sinswirl","duatwist","shacklevoid","psyonium","ectoswirl","impite","ghouline","increpus","stygius",
}

-- =================================
-- TAB DEFINITIONS (chip text -> table key)
-- =================================
local TAB_DEFS = {
	-- W1 Axes
	{ key = "cry_p",    label = "Cry P",    width = 60 },
	{ key = "trin_c",   label = "Trin C",   width = 60 },
	{ key = "leaf_57",  label = "57 Leaf",  width = 70 },

	-- W1 Gear
	{ key = "default",  label = "Cyber C",  width = 70 },
	{ key = "lucy",     label = "Lucy L",   width = 60 },
	{ key = "polar_t",  label = "Polar T",  width = 65 },
	{ key = "c_candle", label = "C candle", width = 75 },
	{ key = "elem_t",   label = "Elem T",   width = 65 },
	{ key = "ink_orb",  label = "Ink Orb",  width = 70 },

	-- W2 Axes
	{ key = "moon_s",   label = "Moon S",   width = 70 },
	{ key = "soul_s",   label = "Soul S",   width = 70 },
	{ key = "poc",      label = "POC",      width = 44 },

	-- W2 Gear
	{ key = "shat_h",   label = "Shat H",   width = 70 },
	{ key = "spiral",   label = "Spiral",   width = 62 },
	{ key = "t1_ter",   label = "T1 Ter",   width = 62 },
	{ key = "plas_n",   label = "Plas N",   width = 65 },
	{ key = "c_cb",     label = "C CB",     width = 58 },
	{ key = "vv",       label = "VV",       width = 42 },
	{ key = "cc",       label = "CC",       width = 42 },
	{ key = "oo",       label = "OO",       width = 42 },
	{ key = "ss_t",     label = "SS T",     width = 58 },

	-- SW1 Axes
	{ key = "nos_axe",  label = "Nos Axe",  width = 75 },
	{ key = "nilaxe",   label = "NilAxe",   width = 70 },

	-- SW1 Gear
	{ key = "lut_sup",  label = "Lut Sup",  width = 75 },
	{ key = "lemon",    label = "Lemon",    width = 60 },
	{ key = "esg",      label = "ESG",      width = 50 },
	{ key = "vwv",      label = "VwV",      width = 50 },
	{ key = "sssw",     label = "SSSW",     width = 60 },
	{ key = "tpm",      label = "TPM",      width = 55 },
	{ key = "amb_s",    label = "Amb S",    width = 60 },
	{ key = "ill_ill",  label = "ill ill",  width = 60 },
	{ key = "rgb_c4",   label = "RGB C4",   width = 70 },

	-- SW2 Axes
	{ key = "thun_p",   label = "Thun P",   width = 70 },
	{ key = "yell_a",   label = "Yell A",   width = 70 },
	{ key = "vortaxe",  label = "Vortaxe",  width = 70 },

	-- SW2 Gear
	{ key = "luck_c",   label = "luck C",   width = 65 },
	{ key = "sgr_a",    label = "SGR_A",    width = 65 },
	{ key = "x2_b",     label = "X2-B",     width = 55 },

	-- Digita A
	{ key = "mech_a",   label = "Mech A",   width = 70 },
	{ key = "cyber_d",  label = "Cyber D",  width = 70 },
	{ key = "cod3_b",   label = "Cod3 B",   width = 70 },
	{ key = "g_light",  label = "G light",  width = 70 },
	{ key = "murd_e",   label = "MURD-E",   width = 75 },
	{ key = "plas_rail",label = "Plas Rail",width = 80 },

	-- Digita G
	{ key = "laser_s",  label = "Laser S",  width = 70 },
	{ key = "part_a",   label = "Part A",   width = 60 },
	{ key = "abs_a",    label = "Abs A",    width = 60 },
	{ key = "lspeed",   label = "LSpeed",   width = 70 },
	{ key = "d_gw",     label = "D Gw",     width = 55 },
	{ key = "decons",   label = "DeconS",   width = 70 },
	{ key = "w_star",   label = "W Star",   width = 70 },

	-- Aest A / G
	{ key = "chris_c",  label = "Chris C",  width = 70 },
	{ key = "candy",    label = "Candy",    width = 60 },
	{ key = "love_l",   label = "Love L",   width = 60 },
	{ key = "phan_l",   label = "Phan L",   width = 60 },
	{ key = "heartb",   label = "HeartB",   width = 70 },
	{ key = "f_frag",   label = "F Frag",   width = 65 },
	{ key = "parasol",  label = "Parasol",  width = 70 },
	{ key = "type_s",   label = "Type S",   width = 65 },

	-- Luce A / G
	{ key = "shim_s",   label = "Shim S",   width = 65 },
	{ key = "reaper",   label = "Reaper",   width = 70 },
	{ key = "bosw",     label = "BoSW",     width = 60 },
}

local function getTabDefByKey(key)
	for _, t in ipairs(TAB_DEFS) do
		if t.key == key then return t end
	end
	return nil
end

-- =================================
-- DROPDOWN OPTIONS
-- =================================
local DROPDOWN_OPTIONS = {
	"W1 Axes", "W1 Gear", "W2 Axes", "W2 Gear",
	"SW1 Axes", "SW1 Gear", "SW2 Axes", "SW2 Gear",
	"Digita A", "Digita G",
	"Aest A", "Aest G",
	"Luce A", "Luce G",
}

-- =================================
-- CATEGORY -> TABS (chips shown)
-- =================================
local CATEGORY_TABS = {
	["W1 Axes"]  = { "cry_p", "trin_c", "leaf_57" },
	["W1 Gear"]  = { "default", "lucy", "polar_t", "c_candle", "elem_t", "ink_orb" },

	["W2 Axes"]  = { "moon_s", "soul_s", "poc" },
	["W2 Gear"]  = { "shat_h", "spiral", "t1_ter", "plas_n", "c_cb", "vv", "cc", "oo", "ss_t" },

	["SW1 Axes"] = { "nos_axe", "nilaxe" },
	["SW1 Gear"] = { "lut_sup", "lemon", "esg", "vwv", "sssw", "tpm", "amb_s", "ill_ill", "rgb_c4" },

	["SW2 Axes"] = { "thun_p", "yell_a", "vortaxe" },
	["SW2 Gear"] = { "luck_c", "sgr_a", "x2_b" },

	["Digita A"] = { "mech_a", "cyber_d", "cod3_b", "g_light", "murd_e", "plas_rail" },
	["Digita G"] = { "laser_s", "part_a", "abs_a", "lspeed", "d_gw", "decons", "w_star" },

	["Aest A"]   = { "chris_c" },
	["Aest G"]   = { "candy", "love_l", "phan_l", "heartb", "f_frag", "parasol", "type_s" },

	["Luce A"]   = { "shim_s" },
	["Luce G"]   = { "reaper", "bosw" },
}

-- =================================
-- COLORS (keep your originals + generated)
-- =================================
local oreColors = {
	inclemetite = Color3.fromRGB(255, 120, 120),
	bulbalescense = Color3.fromRGB(255, 200, 80),
	cybernetium = Color3.fromRGB(80, 200, 255),
	glacielle = Color3.fromRGB(180, 220, 255),
	azuryl = Color3.fromRGB(70, 120, 255),
	nauticalis = Color3.fromRGB(80, 255, 200),
	snoblintium = Color3.fromRGB(240, 240, 240),
	freon = Color3.fromRGB(150, 255, 255),
	nuummite = Color3.fromRGB(120, 80, 200),
	nocturnite = Color3.fromRGB(80, 80, 120),
	elysian = Color3.fromRGB(255, 180, 255),
	tanzanite = Color3.fromRGB(140, 90, 255),
	cobalt = Color3.fromRGB(60, 110, 255),
	bluesteel = Color3.fromRGB(100, 160, 200),
	lavendulan = Color3.fromRGB(200, 140, 255),
}

local function generatedColor(name: string): Color3
	local hash = 0
	for i = 1, #name do
		hash = (hash * 31 + string.byte(name, i)) % 360
	end
	return Color3.fromHSV(hash / 360, 0.45, 0.95)
end

local function getOreColor(name: string): Color3
	local raw, stripped = variants(name)
	return oreColors[stripped] or oreColors[raw] or generatedColor(stripped ~= "" and stripped or raw)
end

-- =================================
-- ACTIVE TABLE STATE (variant mapping)
-- =================================
local function buildActiveMaps(list)
	local set = {}
	local variantToDisplay = {}

	for _, display in ipairs(list) do
		local raw, stripped = variants(display)
		set[raw] = true
		variantToDisplay[raw] = display
		if stripped ~= "" then
			set[stripped] = true
			variantToDisplay[stripped] = display
		end
	end

	return set, variantToDisplay
end

local activeKey = "default"
local activeOres = ORE_TABLES[activeKey]
local activeSet, activeVariantToDisplay = buildActiveMaps(activeOres)

local function setActiveTable(key)
	if not ORE_TABLES[key] then return end
	activeKey = key
	activeOres = ORE_TABLES[key]
    
	activeSet, activeVariantToDisplay = buildActiveMaps(activeOres)
end

local IONIZED_MARKER = "__IONIZED__"

local function buildIonizedMarkedSet(list)
	local set = {}
	local nextIsIonized = false

	for _, name in ipairs(list) do
		if name == IONIZED_MARKER then
			nextIsIonized = true
		else
			if nextIsIonized then
				set[name] = true
				nextIsIonized = false -- ONLY the next ore gets tagged
			end
		end
	end

	return set
end


local activeIonizedMarked = buildIonizedMarkedSet(activeOres)


-- =================================
-- ORE SELECTION (checkbox per ore, per tab)
-- =================================
local oreSelectionByKey = {} -- [tableKey] = { [displayOreName] = true/false }
local activeSelection = nil

local function ensureSelectionForKey(key)
	if oreSelectionByKey[key] then return oreSelectionByKey[key] end
	local map = {}
	for _, oreName in ipairs(ORE_TABLES[key] or {}) do
	if oreName ~= IONIZED_MARKER then
		map[oreName] = true
	end
end

	oreSelectionByKey[key] = map
	return map
end

do
	local _setActiveTable = setActiveTable
	function setActiveTable(key)
		if not ORE_TABLES[key] then return end
		_setActiveTable(key)
		activeSelection = ensureSelectionForKey(key)
	end
end

local function getSelectedListForKey(key)
	local sel = ensureSelectionForKey(key)
	local out = {}
	for _, oreName in ipairs(ORE_TABLES[key] or {}) do
		if sel[oreName] == true then
			table.insert(out, oreName)
		end
	end
	return out
end

local function buildSelectedSetForKey(key)
	-- returns a robust variants set like your other code uses
	local list = getSelectedListForKey(key)
	return select(1, buildActiveMaps(list))
end



-- =================================
-- UI
-- =================================
local gui = Instance.new("ScreenGui")
gui.Name = "OreToolsUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -20, 0, 80)
frame.Size = UDim2.fromOffset(280, 360) -- slightly wider
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.ZIndex = 1
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Header row
local header = Instance.new("Frame")
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(10, 6)
header.Size = UDim2.new(1, -20, 0, 26)
header.ZIndex = 2
header.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 0)
title.Size = UDim2.fromOffset(72, 26)
title.Text = "Ore Scanner"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = header

-- Dropdown button beside title
local ddBtn = Instance.new("TextButton")
ddBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ddBtn.BorderSizePixel = 0
ddBtn.Position = UDim2.fromOffset(76, 2)
ddBtn.Size = UDim2.fromOffset(90, 22)
ddBtn.Text = "W1 Gear ▾"
ddBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
ddBtn.Font = Enum.Font.GothamSemibold
ddBtn.TextSize = 12
ddBtn.ZIndex = 2
ddBtn.Parent = header
local ddCorner = Instance.new("UICorner")
ddCorner.CornerRadius = UDim.new(0, 7)
ddCorner.Parent = ddBtn

-- Close button on far right
local closeBtn = Instance.new("TextButton")
closeBtn.BackgroundTransparency = 1
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, 0, 0, 1)
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 2
closeBtn.Parent = header

-- Horizontal chip bar to the right of dropdown and left of X
local quickBar = Instance.new("ScrollingFrame")
quickBar.BackgroundTransparency = 1
quickBar.BorderSizePixel = 0
quickBar.Position = UDim2.fromOffset(172, 0)
quickBar.Size = UDim2.new(1, -172 - 26, 1, 0)
quickBar.ScrollBarThickness = 3
quickBar.ScrollBarImageTransparency = 0.35
quickBar.ScrollingDirection = Enum.ScrollingDirection.X
quickBar.CanvasSize = UDim2.new(0, 0, 0, 0)
quickBar.ZIndex = 2
quickBar.Parent = header

local quickLayout = Instance.new("UIListLayout")
quickLayout.FillDirection = Enum.FillDirection.Horizontal
quickLayout.Padding = UDim.new(0, 6)
quickLayout.Parent = quickBar

quickLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	quickBar.CanvasSize = UDim2.fromOffset(quickLayout.AbsoluteContentSize.X + 6, 0)
end)

-- Dropdown menu (appears under dropdown button)
local ddMenu = Instance.new("Frame")
ddMenu.Visible = false
ddMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ddMenu.BorderSizePixel = 0
ddMenu.Position = UDim2.new(0, 76, 0, 30)
ddMenu.Size = UDim2.fromOffset(150, (#DROPDOWN_OPTIONS * 24) + 8)
ddMenu.ZIndex = 50 -- IMPORTANT: above list text
ddMenu.Parent = frame
local ddMenuCorner = Instance.new("UICorner")
ddMenuCorner.CornerRadius = UDim.new(0, 8)
ddMenuCorner.Parent = ddMenu

local ddList = Instance.new("UIListLayout")
ddList.Padding = UDim.new(0, 4)
ddList.SortOrder = Enum.SortOrder.LayoutOrder
ddList.Parent = ddMenu

local ddPad = Instance.new("UIPadding")
ddPad.PaddingTop = UDim.new(0, 6)
ddPad.PaddingBottom = UDim.new(0, 6)
ddPad.PaddingLeft = UDim.new(0, 6)
ddPad.PaddingRight = UDim.new(0, 6)
ddPad.Parent = ddMenu

-- Progress label
local progressLbl = Instance.new("TextLabel")
progressLbl.BackgroundTransparency = 1
progressLbl.Position = UDim2.fromOffset(10, 30)
progressLbl.Size = UDim2.new(1, -20, 0, 18)
progressLbl.TextColor3 = Color3.fromRGB(190, 190, 190)
progressLbl.Font = Enum.Font.GothamSemibold
progressLbl.TextSize = 12
progressLbl.TextXAlignment = Enum.TextXAlignment.Left
progressLbl.ZIndex = 1
progressLbl.Parent = frame

-- Ore list
local list = Instance.new("ScrollingFrame")
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.Position = UDim2.fromOffset(10, 50)
list.Size = UDim2.new(1, -20, 1, -102)
list.ScrollBarImageTransparency = 0.5
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ZIndex = 1
list.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = list
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 6)
end)

-- Bottom row (TP + HC)
local row = Instance.new("Frame")
row.BackgroundTransparency = 1
row.Position = UDim2.new(0, 10, 1, -46)
row.Size = UDim2.new(1, -20, 0, 36)
row.ZIndex = 1
row.Parent = frame

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rowLayout.Padding = UDim.new(0, 8)
rowLayout.Parent = row

local function makeBtn(text, wScale)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, 0, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(235, 235, 235)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 13
	b.ZIndex = 1
	b.Parent = row
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	return b
end

local tpButton = makeBtn("Start TP", 0.55)
local hcButton = makeBtn("HC : OFF", 0.45)

-- Reopen button
local reopen = Instance.new("TextButton")
reopen.AnchorPoint = Vector2.new(1, 0)
reopen.Position = UDim2.new(1, -20, 0, 20)
reopen.Size = UDim2.fromOffset(80, 28)
reopen.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
reopen.BorderSizePixel = 0
reopen.Text = "Open"
reopen.TextColor3 = Color3.fromRGB(235, 235, 235)
reopen.Font = Enum.Font.GothamSemibold
reopen.TextSize = 13
reopen.Visible = false
reopen.ZIndex = 1
reopen.Parent = gui
local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 8)
reopenCorner.Parent = reopen

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	reopen.Visible = true
	ddMenu.Visible = false
end)

reopen.MouseButton1Click:Connect(function()
	frame.Visible = true
	reopen.Visible = false
end)

-- =================================
-- TP PROGRESS (ONLY during TP, mined/total locked at start)
-- =================================
local tpProgress = {}
for key, _ in pairs(ORE_TABLES) do
	tpProgress[key] = { running = false, mined = 0, total = 0 }
end

local function updateProgressLabel()
	local p = tpProgress[activeKey]
	if p and p.running then
		progressLbl.Text = string.format("TP Progress: %d/%d", p.mined, p.total)
	else
		progressLbl.Text = "TP Progress: -"
	end
end

local function countSpawnedForSet(setTbl)
	local n = 0
	for _, obj in ipairs(mine:GetChildren()) do
		local raw, stripped = variants(obj.Name)
		if setTbl[raw] or (stripped ~= "" and setTbl[stripped]) then
			local display = activeVariantToDisplay[raw] or (stripped ~= "" and activeVariantToDisplay[stripped]) or nil
			if display and activeIonizedMarked[display] then
				if isIonizedOre(obj) then
					n += 1
				end
			else
				n += 1
			end
		end
	end
	return n
end



-- =================================
-- SCANNER DISPLAY (refresh every 2s)
-- =================================
local function rgb(c)
	return math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
end

local function scanCountsActive()
	local counts = {}
	for _, displayName in ipairs(activeOres) do
		if displayName ~= IONIZED_MARKER then
			counts[displayName] = 0
		end
	end

	for _, obj in ipairs(mine:GetChildren()) do
		local raw, stripped = variants(obj.Name)
		local display = activeVariantToDisplay[raw] or (stripped ~= "" and activeVariantToDisplay[stripped]) or nil
		if display and counts[display] ~= nil then
			if activeIonizedMarked[display] then
				if isIonizedOre(obj) then
					counts[display] += 1
				end
			else
				counts[display] += 1
			end
		end
	end

	return counts
end


local function clearRows()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function refreshScannerUI()
	clearRows()
	activeSelection = activeSelection or ensureSelectionForKey(activeKey)

	local counts = scanCountsActive()

	for _, oreName in ipairs(activeOres) do
		if oreName == IONIZED_MARKER then
			continue
		end

		local c = getOreColor(oreName)
		local r, g, b = rgb(c)
		local count = counts[oreName] or 0

		local rowFrame = Instance.new("Frame")
		rowFrame.BackgroundTransparency = 1
		rowFrame.Size = UDim2.new(1, 0, 0, 22)
		rowFrame.ZIndex = 1
		rowFrame.Parent = list

		-- Checkbox
		local checkBtn = Instance.new("TextButton")
		checkBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		checkBtn.BorderSizePixel = 0
		checkBtn.Position = UDim2.fromOffset(0, 2)
		checkBtn.Size = UDim2.fromOffset(18, 18)
		checkBtn.Font = Enum.Font.GothamBold
		checkBtn.TextSize = 14
		checkBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
		checkBtn.ZIndex = 2
		checkBtn.Parent = rowFrame

		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 4)
		cc.Parent = checkBtn

		local function renderCheck()
			checkBtn.Text = (activeSelection[oreName] == true) and "✓" or ""
		end
		renderCheck()

		checkBtn.MouseButton1Click:Connect(function()
			activeSelection[oreName] = not (activeSelection[oreName] == true)
			renderCheck()
		end)

		local checked = (activeSelection[oreName] == true)
		local isIonizedMarked = (activeIonizedMarked[oreName] == true)

		-- Animated IONIZED label (separate so it can have UIGradient)
		local ionTagWidth = 0
		if isIonizedMarked then
			local ionTag = Instance.new("TextLabel")
			ionTag.BackgroundTransparency = 1
			ionTag.Position = UDim2.fromOffset(24, 0) -- after checkbox
			ionTag.Size = UDim2.fromOffset(70, 22)
			ionTag.Font = Enum.Font.GothamBold
			ionTag.TextSize = 13
			ionTag.TextXAlignment = Enum.TextXAlignment.Left
			ionTag.Text = "IONIZED"
			ionTag.TextColor3 = Color3.new(1, 1, 1)
			ionTag.ZIndex = 2
			ionTag.Parent = rowFrame

			local grad = Instance.new("UIGradient")
			grad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
			})
			grad.Offset = Vector2.new(-1, 0)
			grad.Parent = ionTag

			task.spawn(function()
				while ionTag.Parent do
					grad.Offset = Vector2.new(grad.Offset.X + 0.03, 0)
					if grad.Offset.X > 1 then
						grad.Offset = Vector2.new(-1, 0)
					end
					task.wait(0.03)
				end
			end)

			ionTagWidth = 70
		end

		-- Main name + count label (shift right if ionized tag exists)
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.fromOffset(24 + (isIonizedMarked and (ionTagWidth + 6) or 0), 0)
		lbl.Size = UDim2.new(1, -(24 + (isIonizedMarked and (ionTagWidth + 6) or 0)), 1, 0)
		lbl.RichText = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.ZIndex = 1
		lbl.Parent = rowFrame

		if checked then
			lbl.Text = string.format(
				'<font color="rgb(%d,%d,%d)">%s</font> <font color="rgb(200,200,200)">%d</font>',
				r, g, b, oreName, count
			)
		else
			lbl.Text = string.format(
				'<font color="rgb(140,140,140)">%s</font> <font color="rgb(120,120,120)">%d</font>',
				oreName, count
			)
		end
	end
end



-- =================================
-- CHIPS (dynamic based on dropdown category)
-- =================================
local chipButtons = {} -- [key] = button
local allowedTabs = CATEGORY_TABS["W1 Gear"]

local function makeChip(text, width)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.BorderSizePixel = 0
	b.Size = UDim2.fromOffset(width or 60, 22)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(235, 235, 235)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 12
	b.ZIndex = 2
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = b
	return b
end

local function setChipActive(btn, on)
	btn.TextColor3 = on and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(235, 235, 235)
end

local function isAllowed(key)
	for _, k in ipairs(allowedTabs) do
		if k == key then return true end
	end
	return false
end

local function rebuildChips()
	for _, child in ipairs(quickBar:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	table.clear(chipButtons)

	for _, key in ipairs(allowedTabs) do
		local def = getTabDefByKey(key)
		if def then
			local chip = makeChip(def.label, def.width)
			chip.Parent = quickBar
			chipButtons[key] = chip

			chip.MouseButton1Click:Connect(function()
				setActiveTable(key)
				for k, b in pairs(chipButtons) do
					setChipActive(b, k == activeKey)
				end
				refreshScannerUI()
				updateProgressLabel()
			end)
		end
	end

	if not isAllowed(activeKey) then
		local first = allowedTabs[1]
		if first then setActiveTable(first) end
	end

	for k, b in pairs(chipButtons) do
		setChipActive(b, k == activeKey)
	end
end

-- =================================
-- DROPDOWN MENU
-- =================================
local currentCategory = "W1 Gear"

local function setCategory(cat)
	currentCategory = cat
	ddBtn.Text = cat .. " ▾"

	allowedTabs = CATEGORY_TABS[cat] or { "default" }
	rebuildChips()
	refreshScannerUI()
	updateProgressLabel()
end

local function makeDdOption(text)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	b.BorderSizePixel = 0
	b.Size = UDim2.new(1, 0, 0, 22)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(235, 235, 235)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 12
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.ZIndex = 51
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.Parent = b
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = b
	return b
end

for _, opt in ipairs(DROPDOWN_OPTIONS) do
	local b = makeDdOption(opt)
	b.Parent = ddMenu
	b.MouseButton1Click:Connect(function()
		ddMenu.Visible = false
		setCategory(opt)
	end)
end

ddBtn.MouseButton1Click:Connect(function()
	ddMenu.Visible = not ddMenu.Visible
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if not ddMenu.Visible then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	local mousePos = UserInputService:GetMouseLocation()
	local function inside(guiObj)
		local pos, size = guiObj.AbsolutePosition, guiObj.AbsoluteSize
		return mousePos.X >= pos.X and mousePos.X <= pos.X + size.X
			and mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
	end

	if not inside(ddMenu) and not inside(ddBtn) then
		ddMenu.Visible = false
	end
end)

-- =================================
-- PLATFORM + TELEPORT HELPERS
-- =================================
local function createPlatform()
	local p = Instance.new("Part")
	p.Name = "LocalOrePlatform"
	p.Size = Vector3.new(16, 1, 16)
	p.Anchored = true
	p.CanCollide = true
	p.Transparency = 0.4
	p.Parent = workspace
	return p
end

local function getOreCFrame(ore)
	if ore:IsA("BasePart") then
		return ore.CFrame
	elseif ore:IsA("Model") then
		if ore.PrimaryPart then
			return ore.PrimaryPart.CFrame
		end
		local part = ore:FindFirstChildWhichIsA("BasePart", true)
		if part then return part.CFrame end
	end
	return nil
end

local function teleportToOre(ore, platform)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local cf = getOreCFrame(ore)
	if not cf then return false end

	platform.CFrame = cf * CFrame.new(0, -3, 0)
	hrp.CFrame = cf * CFrame.new(0, 4, 0)
	return true
end

local function waitUntilOreGone(ore, maxSeconds)
	local t0 = os.clock()
	while os.clock() - t0 < maxSeconds do
		if ore == nil or ore.Parent == nil or not ore:IsDescendantOf(mine) then
			return true
		end
		RunService.Heartbeat:Wait()
	end
	return false
end

-- =================================
-- NOCLIP (ONLY during TP)
-- =================================
local noclipOn = false
local noclipConn = nil
local savedCanCollide = {} -- [BasePart] = originalCanCollide

local function applyNoclipToCharacter(char: Model)
	for _, inst in ipairs(char:GetDescendants()) do
		if inst:IsA("BasePart") then
			if savedCanCollide[inst] == nil then
				savedCanCollide[inst] = inst.CanCollide
			end
			inst.CanCollide = false
		end
	end
end

local function restoreCharacterCollisions()
	for part, original in pairs(savedCanCollide) do
		if part and part.Parent then
			part.CanCollide = original
		end
	end
	table.clear(savedCanCollide)
end

local function enableNoclip()
	if noclipOn then return end
	noclipOn = true

	local function step()
		if not noclipOn then return end
		local char = player.Character
		if char then
			applyNoclipToCharacter(char)
		end
	end

	noclipConn = RunService.Stepped:Connect(step)
	step()
end

local function disableNoclip()
	if not noclipOn then return end
	noclipOn = false
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end
	restoreCharacterCollisions()
end

player.CharacterAdded:Connect(function()
	-- If they respawn mid-TP, keep noclip applied.
	if noclipOn then
		task.wait(0.1)
		local char = player.Character
		if char then applyNoclipToCharacter(char) end
	end
end)

-- =================================
-- ORE TELEPORT (mined grows, /total stays fixed)
-- =================================
local runningTP = false

local function runOreLoop()
	if runningTP then return end
	runningTP = true
	tpButton.Text = "TP : RUN"

	local myKey = activeKey
local mySet = buildSelectedSetForKey(myKey) -- ONLY checked ores

-- If nothing is checked, don't run
if not mySet or next(mySet) == nil then
	progressLbl.Text = "TP Progress: (check at least 1 ore)"
	tpButton.Text = "Start TP"
	runningTP = false
	return
end

local totalAtStart = countSpawnedForSet(mySet)


	tpProgress[myKey].running = true
	tpProgress[myKey].mined = 0
	tpProgress[myKey].total = totalAtStart
	if activeKey == myKey then updateProgressLabel() end

	local platform = createPlatform()

	task.spawn(function()
	-- Turn on noclip for the whole TP process
	enableNoclip()

	local function finish()
		disableNoclip()
		if platform then platform:Destroy() end
		tpButton.Text = "Start TP"
		runningTP = false
		tpProgress[myKey].running = false
		if activeKey == myKey then updateProgressLabel() end
	end

	if totalAtStart <= 0 then
		finish()
		return
	end

	while tpProgress[myKey].mined < totalAtStart do
		local target

		for _, obj in ipairs(mine:GetChildren()) do
			local raw, stripped = variants(obj.Name)

			if mySet[raw] or (stripped ~= "" and mySet[stripped]) then
				local display = activeVariantToDisplay[raw]
					or (stripped ~= "" and activeVariantToDisplay[stripped])
					or nil

				if display and activeIonizedMarked[display] then
					if isIonizedOre(obj) then
						target = obj
						break
					end
				else
					target = obj
					break
				end
			end
		end

		if not target then break end

		local ok = teleportToOre(target, platform)
		if ok then
			local gone = waitUntilOreGone(target, 30)
			if gone then
				tpProgress[myKey].mined += 1
				if activeKey == myKey then updateProgressLabel() end
			end
		else
			task.wait(0.1)
		end
	end

	finish()
end) -- ✅ closes task.spawn(function()

end

tpButton.MouseButton1Click:Connect(runOreLoop)

-- =================================
-- HC TOGGLE
-- =================================
local hcOn = false
local hcLoopRunning = false

local function updateHC()
	hcButton.Text = hcOn and "HC : ON" or "HC : OFF"
	hcButton.TextColor3 = hcOn and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 90, 90)
end

local function startHCLoop()
	if hcLoopRunning then return end
	hcLoopRunning = true
	task.spawn(function()
		while hcOn do
			pcall(callHC)
			task.wait(5)
		end
		hcLoopRunning = false
	end)
end

hcButton.MouseButton1Click:Connect(function()
	hcOn = not hcOn
	updateHC()
	if hcOn then startHCLoop() end
end)

-- =================================
-- AUTO REFRESH (scanner only)
-- =================================
task.spawn(function()
	while true do
		if frame.Visible then
			refreshScannerUI()
		end
		task.wait(2)
	end
end)

-- =================================
-- INIT
-- =================================
updateHC()
setCategory("W1 Gear")
refreshScannerUI()
updateProgressLabel()
