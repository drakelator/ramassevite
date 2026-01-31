# Force UTF-8
$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 1. CONFIGURATION ---

# Extended City List (Regions for internal linking logic)
$rive_sud = @(
    "Longueuil", "Boucherville", "Brossard", "Saint-Lambert", "Saint-Bruno-de-Montarville", "Beloeil", "Chambly", 
    "La Prairie", "Saint-Constant", "Mercier", "Sainte-Julie", "Saint-Amable", "Carignan", "Candiac", "Sainte-Catherine", 
    "Delson", "Saint-Philippe", "Saint-Jean-sur-Richelieu", "Salaberry-de-Valleyfield", "Sorel-Tracy", "Saint-Hyacinthe", 
    "Beauharnois", "Contrecoeur", "Verch$([char]0xE8)res", "Mont-Saint-Hilaire", "McMasterville", "Saint-Basile-le-Grand", 
    "Otterburn Park", "Marieville", "Varennes", "Vaudreuil-Dorion", "Pincourt", "L'$([char]0xCE)le-Perrot", "Saint-Lazare", 
    "Les C$([char]0xE8)dres", "Hudson", "Saint-Zotique", "Coteau-du-Lac", "Les Coteaux",
    "Ch$([char]0xE2)teauguay", "Saint-R$([char]0xE9)mi", "Napierville", "Kahnawake", "Saint-Mathieu", "Saint-Isidore"
)

$montreal_core = @(
    "Montr$([char]0xE9)al", "Ahuntsic", "Anjou", "C$([char]0xF4)te-des-Neiges", "Notre-Dame-de-Gr$([char]0xE2)ce", "Lachine", "LaSalle", 
    "Le Plateau-Mont-Royal", "Le Sud-Ouest", "Hochelaga-Maisonneuve", "Montr$([char]0xE9)al-Nord", "Outremont", "Verdun", 
    "Ville-Marie", "Villeray", "Saint-Michel", "Parc-Extension", "Westmount", "Griffintown", "Rosemont", 
    "La Petite-Patrie", "Saint-Laurent", "Saint-L$([char]0xE9)onard", "Montr$([char]0xE9)al-Est", "Rivi$([char]0xE8)re-des-Prairies", "Pointe-aux-Trembles", "Pierrefonds"
)

$west_island = @(
    "Dollard-des-Ormeaux", "Pointe-Claire", "Kirkland", "Beaconsfield", "Baie-d'Urf$([char]0xE9)", "Sainte-Anne-de-Bellevue", 
    "Senneville", "Dorval", "L'$([char]0xCE)le-Bizard"
)

# Combine for iteration
$all_locations = $rive_sud + $montreal_core + $west_island

# Helper: Get-Slug (Hardened)
function Get-Slug {
    param ([string]$text)
    $text = $text -replace [char]0xE9, 'e' # é
    $text = $text -replace [char]0xE8, 'e' # è
    $text = $text -replace [char]0xEA, 'e' # ê
    $text = $text -replace [char]0xEB, 'e' # ë
    $text = $text -replace [char]0xE0, 'a' # à
    $text = $text -replace [char]0xE2, 'a' # â
    $text = $text -replace [char]0xF4, 'o' # ô
    $text = $text -replace [char]0xCE, 'i' # Î
    $text = $text -replace [char]0xEF, 'i' # ï
    $text = $text -replace [char]0xEE, 'i' # î
    $text = $text -replace [char]0xE7, 'c' # ç
    $text = $text -replace [char]0xF9, 'u' # ù
    $text = $text -replace [char]0xFB, 'u' # û
    $text = $text -replace "'", ""         # Remove apostrophes (l'ile -> lile)
    
    $text = $text.Normalize([System.Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder
    foreach ($c in $text.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$builder.Append($c) }
    }
    $slug = $builder.ToString().Normalize([System.Text.NormalizationForm]::FormC).ToLower() -replace '[^a-z0-9\s-]', '' -replace '\s+', '-' -replace '-+', '-'
    return $slug
}

# Helper: Get-Nearby-Links
function Get-Nearby-Links {
    param ($currentCity, $regionArray)
    $others = $regionArray | Where-Object { $_ -ne $currentCity } | Get-Random -Count 6
    $links = ""
    foreach ($o in $others) {
        $s = Get-Slug $o
        $links += "<li><a href='service-ramassage-$s.html'>$o</a></li>`n"
    }
    return "<ul>$links</ul>"
}

function Get-Nearby-Links-En {
    param ($currentCity, $regionArray)
    $others = $regionArray | Where-Object { $_ -ne $currentCity } | Get-Random -Count 6
    $links = ""
    foreach ($o in $others) {
        $s = Get-Slug $o
        $links += "<li><a href='pickup-service-$s.html'>$o</a></li>`n"
    }
    return "<ul>$links</ul>"
}

# --- 2. CONTENT VARIATIONS (Unique paragraphs - Escaped for Safety) ---

$fr_services_paragraphs = @(
    "Nous comprenons que chaque propri$([char]0xE9)t$([char]0xE9) $([char]0xE0) {{CITY_NAME}} a ses particularit$([char]0xE9)s. Que vous viviez dans un condo au centre-ville avec un acc$([char]0xE8)s restreint ou dans une maison unifamiliale avec un sous-sol encombr$([char]0xE9), notre $([char]0xE9)quipe s'adapte. Nous prot$([char]0xE9)geons vos murs et planchers lors de la manipulation d'objets lourds.",
    "$([char]0xC0) {{CITY_NAME}}, le ramassage d'encombrants peut $([char]0xEA)tre un d$([char]0xE9)fi, surtout avec les horaires stricts des collectes municipales. Ramasse Vite vous lib$([char]0xE8)re de ces contraintes en passant quand VOUS le voulez. Id$([char]0xE9)al pour les r$([char]0xE9)novations, les d$([char]0xE9)m$([char]0xE9)nagements ou simplement pour faire de la place dans le garage.",
    "Notre service $([char]0xE0) {{CITY_NAME}} est con$([char]0xE7)u pour $([char]0xEA)tre cl$([char]0xE9) en main. Vous n'avez rien $([char]0xE0) sortir sur le trottoir. Nos techniciens entrent, ramassent, nettoient et partent. Nous desservons tous les quartiers, des zones r$([char]0xE9)sidentielles paisibles aux secteurs commerciaux plus denses.",
    "L'$([char]0xE9)cologie est au coeur de notre action $([char]0xE0) {{CITY_NAME}}. Nous trions m$([char]0xE9)ticuleusement les mati$([char]0xE8)res dans nos camions pour maximiser le recyclage et le don aux organismes locaux. Vos vieux meubles et $([char]0xE9)lectros auront une seconde vie ou seront dispos$([char]0xE9)s de mani$([char]0xE8)re $([char]0xE9)cologique, loin des sites d'enfouissement.",
    "Particuliers et entreprises de {{CITY_NAME}} font appel $([char]0xE0) nous pour notre rapidit$([char]0xE9). Souvent disponibles le jour m$([char]0xEA)me, nous sommes la solution parfaite pour les urgences : fin de bail, vente de maison, ou d$([char]0xE9)g$([char]0xE2)t d'eau. Une $([char]0xE9)quipe forte, polie et efficace $([char]0xE0) votre service.",
    "Acc$([char]0xE8)s difficile ? Escaliers en colima$([char]0xE7)on ? Aucun probl$([char]0xE8)me pour nos experts $([char]0xE0) {{CITY_NAME}}. Nous avons l'$([char]0xE9)quipement et l'exp$([char]0xE9)rience pour sortir les objets les plus volumineux sans rien ab$([char]0xEE)mer. Laissez-nous forcer pendant que vous retrouvez votre tranquillit$([char]0xE9) d'esprit.",
    "Nous offrons une tarification transparente pour les r$([char]0xE9)sidents de {{CITY_NAME}}. Pas de surprise : le prix est bas$([char]0xE9) sur le volume que vos objets occupent dans notre camion. C'est simple, honn$([char]0xEA)te et beaucoup moins compliqu$([char]0xE9) que de louer un conteneur.",
    "Faites confiance $([char]0xE0) une $([char]0xE9)quipe locale qui conna$([char]0xEE)t bien {{CITY_NAME}}. Nous savons o$([char]0xF9) se trouvent les $([char]0xE9)cocentres et les centres de dons partenaires, ce qui nous permet d'$([char]0xEA)tre plus efficaces et plus verts. Votre d$([char]0xE9)barras contribue $([char]0xE0) l'$([char]0xE9)conomie circulaire locale."
)

$en_services_paragraphs = @(
    "We understand that every property in {{CITY_NAME}} is unique. Whether you live in a downtown condo with tight access or a detached home with a cluttered basement, our team adapts. We protect your walls and floors while handling heavy items, ensuring a damage-free service.",
    "In {{CITY_NAME}}, getting rid of bulk items can be a hassle given strict municipal schedules. Ramasse Vite frees you from these constraints by coming when YOU need us. Perfect for renovations, moving out, or simply clearing out the garage.",
    "Our service in {{CITY_NAME}} is fully turnkey. You don't need to drag anything to the curb. Our technicians come in, load up, sweep up, and head out. We serve all neighborhoods, from quiet residential streets to busy commercial hubs.",
    "Eco-friendliness is at the core of what we do in {{CITY_NAME}}. We meticulously sort materials in our trucks to maximize recycling and donations to local charities. Your old furniture and appliances will get a second life or be disposed of responsibly.",
    "Homeowners and businesses in {{CITY_NAME}} trust us for our speed. Often available for same-day service, we are the perfect solution for urgent needs: lease ends, home sales, or post-disaster cleanups. A strong, polite, and efficient team at your service.",
    "Difficult access? Spiral staircases? No problem for our experts in {{CITY_NAME}}. We have the equipment and experience to remove the bulkiest items without damage. Let us do the heavy lifting while you enjoy your reclaimed space.",
    "We offer transparent pricing for {{CITY_NAME}} residents. No surprises: the price is based strictly on the volume your items take up in our truck. It's simple, honest, and much less hassle than renting a dumpster.",
    "Trust a local team that knows {{CITY_NAME}} inside out. We know the nearest ecocentres and donation partners, allowing us to be more efficient and greener. Your junk removal contributes to the local circular economy."
)

# --- 3. GENERATION LOOP ---

foreach ($city in $all_locations) {
    if ([string]::IsNullOrWhiteSpace($city)) { continue }
    
    $slug = Get-Slug $city
    $fr_filename = "service-ramassage-$slug.html"
    $en_filename = "pickup-service-$slug.html"
    
    # Determine Region for linking
    if ($rive_sud -contains $city) { $region = $rive_sud }
    elseif ($montreal_core -contains $city) { $region = $montreal_core }
    else { $region = $all_locations }

    # Random Content Selection
    $fr_unique = $fr_services_paragraphs | Get-Random
    $en_unique = $en_services_paragraphs | Get-Random
    $fr_nearby = Get-Nearby-Links $city $region
    $en_nearby = Get-Nearby-Links-En $city $region

    # ---------------- FR PAGE GENERATION ----------------
    $fr_html = @"
<!DOCTYPE html>
<html lang="fr-CA" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ramassage d'encombrants $([char]0xE0) $city | Ramasse Vite Rive-Sud</title>
    <meta name="description" content="Service de d$([char]0xE9)barras rapide et $([char]0xE9)coresponsable $([char]0xE0) $city. Meubles, $([char]0xE9)lectros, d$([char]0xE9)bris. Soumission gratuite. Intervention jour m$([char]0xEA)me ou le lendemain.">
    <link rel="canonical" href="https://ramasseviterivesud.com/$fr_filename">
    <meta property="og:title" content="Ramassage d'encombrants $([char]0xE0) $city | RVRS">
    <meta property="og:description" content="D$([char]0xE9)barrassez-vous de vos vieux meubles et d$([char]0xE9)bris $([char]0xE0) $city. Service cl$([char]0xE9) en main.">
    <meta property="og:url" content="https://ramasseviterivesud.com/$fr_filename">
    <meta property="og:image" content="https://ramasseviterivesud.com/images/logo.png">
    <link rel="preload" as="image" href="images/hero-bg.jpg">
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <header>
        <div class="container flex flex-between">
            <a href="index.html" class="flex" style="gap: 15px;">
                <img src="images/logo.png" alt="RVRS Logo" style="height: 50px; width: auto;">
            </a>
            <nav>
                <ul>
                    <li><a href="index.html#services">Services</a></li>
                    <li><a href="index.html#map">Zones</a></li>
                    <li><a href="index.html#prix">Prix</a></li>
                    <li><a href="projets.html">R$([char]0xE9)alisations</a></li>
                </ul>
            </nav>
            <div class="flex">
                <a href="$en_filename" style="color: white; font-weight: 700; margin-right: 15px;">EN</a>
                <a href="tel:+14385271701" class="btn btn-primary" style="background: var(--rvrs-orange); color: white; padding: 12px 24px; font-weight: 700; border-radius: 50px;"><i class="fa-solid fa-phone"></i> 438 527 1701</a>
            </div>
        </div>
    </header>

    <section class="hero" style="padding-top: 120px; min-height: 80vh; display: flex; align-items: center;">
        <div class="container text-center">
            <span style="color: var(--rvrs-orange); font-weight: bold; text-transform: uppercase; letter-spacing: 2px;">Service $city</span>
            <h1 style="font-size: 3.5rem; margin: 20px 0; line-height: 1.1;">Ramassage d'encombrants $([char]0xE0) <span class="text-orange">$city</span></h1>
            <p style="font-size: 1.25rem; color: #ddd; margin-bottom: 30px;">Lib$([char]0xE9)rez votre espace sans effort. Nous faisons tout le travail physique.</p>
            
            <ul style="list-style: none; padding: 0; margin-bottom: 40px; display: flex; justify-content: center; gap: 20px; color: #ccc;">
                <li><i class="fa-solid fa-check text-orange"></i> Rapide (24-48h)</li>
                <li><i class="fa-solid fa-check text-orange"></i> 100% Cl$([char]0xE9) en main</li>
                <li><i class="fa-solid fa-check text-orange"></i> $([char]0xC9)coresponsable</li>
            </ul>

            <div class="flex" style="justify-content: center; gap: 20px; flex-wrap: wrap;">
                <a href="tel:+14385271701" class="btn btn-primary" style="padding: 15px 30px; font-size: 1.1rem;"><i class="fa-solid fa-phone"></i> 438 527 1701</a>
                <a href="index.html#prix" class="btn btn-outline" style="padding: 15px 30px; font-size: 1.1rem;">Obtenir une soumission</a>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center">Services de d$([char]0xE9)barras $([char]0xE0) <span class="text-orange">$city</span></h2>
            <div style="max-width: 800px; margin: 40px auto; text-align: left; background: #1a1a1a; padding: 30px; border-radius: 8px; border-left: 4px solid var(--rvrs-orange);">
                <p style="font-size: 1.1rem; line-height: 1.8; color: #ddd;">$($fr_unique.Replace("{{CITY_NAME}}", "$city"))</p>
                <p style="margin-top: 20px; font-size: 1.1rem; line-height: 1.8; color: #ddd;">Que ce soit pour $([char]0xE9)vacuer des <strong>d$([char]0xE9)bris de r$([char]0xE9)novation</strong>, vider un appartement, ou se d$([char]0xE9)barrasser de vieux meubles, Ramasse Vite Rive-Sud est votre partenaire de confiance $([char]0xE0) $city.</p>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container text-center">
            <h2 style="margin-bottom: 40px;">Ce qu'on ramasse $([char]0xE0) $city</h2>
            <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; text-align: left;">
                <div class="card">
                    <h3 class="text-orange"><i class="fa-solid fa-couch"></i> Meubles & Maison</h3>
                    <ul class="check-list">
                        <li>Sofas, Fauteuils, Divans</li>
                        <li>Tables, Chaises, Bureaux</li>
                        <li>Matelas, Sommiers</li>
                        <li>Tapis, Biblioth$([char]0xE8)ques</li>
                    </ul>
                </div>
                <div class="card">
                    <h3 class="text-orange"><i class="fa-solid fa-plug"></i> $([char]0xC9)lectros & E-Waste</h3>
                    <ul class="check-list">
                        <li>R$([char]0xE9)frig$([char]0xE9)rateurs, Cong$([char]0xE9)lateurs</li>
                        <li>Laveuses, S$([char]0xE9)cheuses</li>
                        <li>Cuisini$([char]0xE8)res, Lave-vaisselle</li>
                        <li>T$([char]0xE9)l$([char]0xE9)visions, Ordinateurs</li>
                    </ul>
                </div>
                <div class="card">
                    <h3 class="text-orange"><i class="fa-solid fa-hammer"></i> D$([char]0xE9)bris & Divers</h3>
                    <ul class="check-list">
                        <li>Bois, M$([char]0xE9)tal, Gypse</li>
                        <li>D$([char]0xE9)bris de r$([char]0xE9)novation</li>
                        <li>Articles de sport, V$([char]0xE9)los</li>
                        <li>Bo$([char]0xEE)tes, Cartons, Papiers</li>
                    </ul>
                </div>
            </div>
            <p style="margin-top: 30px; color: #888;"><em>Note : Nous ne ramassons pas les mati$([char]0xE8)res dangereuses (peinture liquide, solvants, amiante).</em></p>
        </div>
    </section>

    <section class="section">
        <div class="container text-center">
            <h2 style="margin-bottom: 40px;">Comment $([char]0xE7)a marche?</h2>
            <div class="steps-grid" style="text-align: left;">
                <div class="step-item">
                    <h3><div class="step-number">1</div> Contact / Photo</h3>
                    <p>Appelez-nous ou envoyez une photo de vos objets pour une estimation rapide.</p>
                </div>
                <div class="step-item">
                    <h3><div class="step-number">2</div> Prix Clair</h3>
                    <p>Nous vous donnons un prix fixe bas$([char]0xE9) sur le volume. Pas de frais cach$([char]0xE9)s.</p>
                </div>
                <div class="step-item">
                    <h3><div class="step-number">3</div> On Ramasse</h3>
                    <p>Notre $([char]0xE9)quipe charge tout, nettoie les lieux, et part recycler vos objets.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section bg-card" id="prix">
        <div class="container text-center">
             <h2 style="margin-bottom: 20px;">Nos Prix</h2>
             <p style="max-width: 700px; margin: 0 auto 40px auto; color: #ccc;">Nos tarifs sont bas$([char]0xE9)s sur l'espace que vos objets occupent dans notre camion. La main d'oeuvre et les frais de d$([char]0xE9)placement sont inclus.</p>
             
             <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 40px;">
                <div style="background: #111; padding: 15px; border-radius: 8px;">Minimum (Quelques articles)</div>
                <div style="background: #111; padding: 15px; border-radius: 8px;">1/4 de Camion</div>
                <div style="background: #111; padding: 15px; border-radius: 8px;">1/2 Camion</div>
                <div style="background: #111; padding: 15px; border-radius: 8px;">Camion Plein</div>
             </div>

             <a href="index.html#prix" class="btn btn-primary">Obtenez votre estimation gratuite</a>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center" style="margin-bottom: 40px;">FAQ $([char]0xE0) $city</h2>
            <div class="grid" style="grid-template-columns: 1fr 1fr; gap: 30px;">
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                    <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Intervenez-vous partout $([char]0xE0) $city?</h3>
                    <p style="font-size: 0.95rem; color: #ccc;">Oui, nous couvrons l'ensemble du territoire de $city, que ce soit pour une maison, un appartement ou un commerce.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Vos prix incluent-ils les frais d'$([char]0xE9)cocentre?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Absolument. Nos tarifs incluent la main d'oeuvre, le transport, et les frais de disposition/recyclage.</p>
                </div>
                 <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Faut-il pr$([char]0xE9)parer les objets?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Non, tant que c'est accessible. Rassemblez les petits objets en bo$([char]0xEE)tes si possible pour acc$([char]0xE9)l$([char]0xE9)rer le processus.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Ramassez-vous $([char]0xE0) l'$([char]0xE9)tage?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Oui, notre $([char]0xE9)quipe est habitu$([char]0xE9)e aux escaliers et ascenseurs de $city. Nous faisons le travail physique pour vous.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Quels d$([char]0xE9)lais pour $city?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Nous visons un service dans les 24 $([char]0xE0) 48h. Appelez-nous le matin pour v$([char]0xE9)rifier les disponibilit$([char]0xE9)s du jour m$([char]0xEA)me.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container">
            <h3 style="margin-bottom: 20px;">Zones desservies pr$([char]0xE8)s de $city</h3>
            <div class="footer-links" style="column-count: 3; column-gap: 20px;">
                $fr_nearby
            </div>
        </div>
    </section>

    <footer>
        <div class="container footer-grid">
            <div>
                <a href="index.html" class="flex" style="gap: 10px; margin-bottom: 20px;">
                    <span style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">RVRS</span>
                    <span style="font-size: 1.5rem; font-weight: 700; color: white;">Ramasse Vite</span>
                </a>
                <p>Service de d$([char]0xE9)barras professionnel $([char]0xE0) $city et environs.</p>
            </div>
            <div class="footer-links">
                <h4 class="text-orange">Contact</h4>
                <ul>
                    <li><a href="tel:+14385271701">438-527-1701</a></li>
                    <li><a href="mailto:Ramassevite.soumission@outlook.com">Email</a></li>
                </ul>
            </div>
        </div>
        <div class="text-center" style="margin-top: 20px; font-size: 0.8rem; color: #555;">&copy; 2026 Ramasse Vite Rive-Sud.</div>
    </footer>
    
    <script src="app.js"></script>
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "LocalBusiness",
          "name": "Ramasse Vite - $city",
          "telephone": "+14385271701",
          "url": "https://ramasseviterivesud.com/$fr_filename",
          "address": {"@type": "PostalAddress", "addressLocality": "$city", "addressRegion": "QC", "addressCountry": "CA"},
          "priceRange": "$$"
        }
      ]
    }
    </script>
</body>
</html>
"@

    # ---------------- EN PAGE GENERATION ----------------
    $en_html = @"
<!DOCTYPE html>
<html lang="en-CA" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Junk Removal Service in $city | Ramasse Vite Rive-Sud</title>
    <meta name="description" content="Fast and eco-friendly junk removal in $city. Furniture, appliances, debris. Free quote. Same day or next day service.">
    <link rel="canonical" href="https://ramasseviterivesud.com/$en_filename">
    <meta property="og:title" content="Junk Removal Service in $city | RVRS">
    <meta property="og:description" content="Get rid of old furniture and debris in $city. Turnkey service.">
    <meta property="og:url" content="https://ramasseviterivesud.com/$en_filename">
    <meta property="og:image" content="https://ramasseviterivesud.com/images/logo.png">
    <link rel="preload" as="image" href="images/hero-bg.jpg">
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <header>
        <div class="container flex flex-between">
            <a href="index-en.html" class="flex" style="gap: 15px;">
                <img src="images/logo.png" alt="RVRS Logo" style="height: 50px; width: auto;">
            </a>
            <nav>
                <ul>
                    <li><a href="index-en.html#services">Services</a></li>
                    <li><a href="index-en.html#map">Areas</a></li>
                    <li><a href="index-en.html#prix">Pricing</a></li>
                    <li><a href="projets.html">Projects</a></li>
                </ul>
            </nav>
            <div class="flex">
                <a href="$fr_filename" style="color: white; font-weight: 700; margin-right: 15px;">FR</a>
                <a href="tel:+14385271701" class="btn btn-primary" style="background: var(--rvrs-orange); color: white; padding: 12px 24px; font-weight: 700; border-radius: 50px;"><i class="fa-solid fa-phone"></i> 438 527 1701</a>
            </div>
        </div>
    </header>

    <section class="hero" style="padding-top: 120px; min-height: 80vh; display: flex; align-items: center;">
        <div class="container text-center">
            <span style="color: var(--rvrs-orange); font-weight: bold; text-transform: uppercase; letter-spacing: 2px;">Service $city</span>
            <h1 style="font-size: 3.5rem; margin: 20px 0; line-height: 1.1;">Junk Removal in <span class="text-orange">$city</span></h1>
            <p style="font-size: 1.25rem; color: #ddd; margin-bottom: 30px;">Clear your space effortlessly. We do all the heavy lifting.</p>
            
            <ul style="list-style: none; padding: 0; margin-bottom: 40px; display: flex; justify-content: center; gap: 20px; color: #ccc;">
                <li><i class="fa-solid fa-check text-orange"></i> Fast (24-48h)</li>
                <li><i class="fa-solid fa-check text-orange"></i> 100% Turnkey</li>
                <li><i class="fa-solid fa-check text-orange"></i> Eco-friendly</li>
            </ul>

            <div class="flex" style="justify-content: center; gap: 20px; flex-wrap: wrap;">
                <a href="tel:+14385271701" class="btn btn-primary" style="padding: 15px 30px; font-size: 1.1rem;"><i class="fa-solid fa-phone"></i> 438 527 1701</a>
                <a href="index-en.html#prix" class="btn btn-outline" style="padding: 15px 30px; font-size: 1.1rem;">Get a Quote</a>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center">Debris Removal Services in <span class="text-orange">$city</span></h2>
            <div style="max-width: 800px; margin: 40px auto; text-align: left; background: #1a1a1a; padding: 30px; border-radius: 8px; border-left: 4px solid var(--rvrs-orange);">
                <p style="font-size: 1.1rem; line-height: 1.8; color: #ddd;">$($en_unique.Replace("{{CITY_NAME}}", "$city"))</p>
                <p style="margin-top: 20px; font-size: 1.1rem; line-height: 1.8; color: #ddd;">Whether clearing out <strong>renovation debris</strong>, emptying an apartment, or getting rid of old furniture, Ramasse Vite Rive-Sud is your trusted partner in $city.</p>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container text-center">
            <h2 style="margin-bottom: 40px;">What We Pick Up in $city</h2>
            <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; text-align: left;">
                <div class="card">
                    <h3 class="text-orange"><i class="fa-solid fa-couch"></i> Furniture & Home</h3>
                    <ul class="check-list">
                        <li>Sofas, Armchairs, Couches</li>
                        <li>Tables, Chairs, Desks</li>
                        <li>Mattresses, Box Springs</li>
                        <li>Carpets, Bookshelves</li>
                    </ul>
                </div>
                <div class="card">
                    <h3 class="text-orange"><i class="fa-solid fa-plug"></i> Appliances & E-Waste</h3>
                    <ul class="check-list">
                        <li>Refrigerators, Freezers</li>
                        <li>Washers, Dryers</li>
                        <li>Stoves, Dishwashers</li>
                        <li>TVs, Computers</li>
                    </ul>
                </div>
                <div class="card">
                    <h3 class="text-orange"><i class="fa-solid fa-hammer"></i> Debris & Misc</h3>
                    <ul class="check-list">
                        <li>Wood, Metal, Drywall</li>
                        <li>Renovation Debris</li>
                        <li>Sports Gear, Bikes</li>
                        <li>Boxes, Cardboard, Paper</li>
                    </ul>
                </div>
            </div>
            <p style="margin-top: 30px; color: #888;"><em>Note: We do not pick up hazardous materials (liquid paint, solvents, asbestos).</em></p>
        </div>
    </section>

    <section class="section">
        <div class="container text-center">
            <h2 style="margin-bottom: 40px;">How It Works</h2>
            <div class="steps-grid" style="text-align: left;">
                <div class="step-item">
                    <h3><div class="step-number">1</div> Contact / Photo</h3>
                    <p>Call us or send a photo of your items for a quick estimate.</p>
                </div>
                <div class="step-item">
                    <h3><div class="step-number">2</div> Clear Pricing</h3>
                    <p>We provide a fixed price based on volume. No hidden fees.</p>
                </div>
                <div class="step-item">
                    <h3><div class="step-number">3</div> We Pick Up</h3>
                    <p>Our team loads everything, cleans up the spot, and leaves to recycle your items.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section bg-card" id="prix">
        <div class="container text-center">
             <h2 style="margin-bottom: 20px;">Our Pricing</h2>
             <p style="max-width: 700px; margin: 0 auto 40px auto; color: #ccc;">Our rates are based on the space your items take up in our truck. Labor and travel fees are included.</p>
             
             <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 40px;">
                <div style="background: #111; padding: 15px; border-radius: 8px;">Minimum (Few items)</div>
                <div style="background: #111; padding: 15px; border-radius: 8px;">1/4 Truck</div>
                <div style="background: #111; padding: 15px; border-radius: 8px;">1/2 Truck</div>
                <div style="background: #111; padding: 15px; border-radius: 8px;">Full Truck</div>
             </div>

             <a href="index-en.html#prix" class="btn btn-primary">Get Your Free Estimate</a>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center" style="margin-bottom: 40px;">FAQ in $city</h2>
            <div class="grid" style="grid-template-columns: 1fr 1fr; gap: 30px;">
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                    <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Do you serve all of $city?</h3>
                    <p style="font-size: 0.95rem; color: #ccc;">Yes, we cover the entire territory of $city, whether for a house, apartment, or business.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Do your prices include eco-center fees?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Absolutely. Our rates include labor, transport, and disposal/recycling fees.</p>
                </div>
                 <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Do I need to prepare the items?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">No, as long as it's accessible. Gathering small items in boxes can speed up the process.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Do you pick up from upper floors?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Yes, our team is accustomed to stairs and elevators in $city. We deal with the physical work for you.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">How fast can you come to $city?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">We aim for service within 24 to 48 hours. Call us in the morning to check same-day availability.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container">
            <h3 style="margin-bottom: 20px;">Service Areas Near $city</h3>
            <div class="footer-links" style="column-count: 3; column-gap: 20px;">
                $en_nearby
            </div>
        </div>
    </section>

    <footer>
        <div class="container footer-grid">
            <div>
                <a href="index-en.html" class="flex" style="gap: 10px; margin-bottom: 20px;">
                    <span style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">RVRS</span>
                    <span style="font-size: 1.5rem; font-weight: 700; color: white;">Ramasse Vite</span>
                </a>
                <p>Professional junk removal service in $city and surroundings.</p>
            </div>
            <div class="footer-links">
                <h4 class="text-orange">Contact</h4>
                <ul>
                    <li><a href="tel:+14385271701">438-527-1701</a></li>
                    <li><a href="mailto:Ramassevite.soumission@outlook.com">Email</a></li>
                </ul>
            </div>
        </div>
        <div class="text-center" style="margin-top: 20px; font-size: 0.8rem; color: #555;">&copy; 2026 Ramasse Vite Rive-Sud.</div>
    </footer>
    
    <script src="app.js"></script>
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "LocalBusiness",
          "name": "Ramasse Vite - $city",
          "telephone": "+14385271701",
          "url": "https://ramasseviterivesud.com/$en_filename",
          "address": {"@type": "PostalAddress", "addressLocality": "$city", "addressRegion": "QC", "addressCountry": "CA"},
          "priceRange": "$$"
        }
      ]
    }
    </script>
</body>
</html>
"@

    # Save Files
    [System.IO.File]::WriteAllText($PWD.Path + "\" + $fr_filename, $fr_html, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($PWD.Path + "\" + $en_filename, $en_html, [System.Text.Encoding]::UTF8)
    Write-Host "Generated: $fr_filename & $en_filename"
}
