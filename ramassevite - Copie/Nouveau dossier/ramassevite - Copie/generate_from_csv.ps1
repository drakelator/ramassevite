# Force UTF-8
$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 1. CONFIGURATION & DATA IMPORT ---
$csvPath = "$PSScriptRoot/cities.csv"
$data = Import-Csv -Path $csvPath

# Helper: Get-Nearby-Links (By Region/Sector)
function Get-Nearby-Links {
    param ($currentCity, $region, $allData, $lang)
    # Filter by same region/sector for relevant linking
    $others = $allData | Where-Object { $_.region -eq $region -and $_.city_display -ne $currentCity } | Get-Random -Count 6
    
    $links = ""
    foreach ($o in $others) {
        if ($lang -eq 'fr') {
             $links += "<li><a href='$($o.fr_filename)'>$($o.city_display)</a></li>`n"
        } else {
             $links += "<li><a href='$($o.en_filename)'>$($o.city_display)</a></li>`n"
        }
    }
    return "<ul>$links</ul>"
}

# --- 2. CONTENT VARIATIONS (Unique paragraphs - Escaped for Safety) ---

$fr_services_paragraphs = @(
    "Nous comprenons que chaque propri$([char]0xE9)t$([char]0xE9) $([char]0xE0) {{CITY_NAME}} a ses particularit$([char]0xE9)s. Que vous viviez dans un condo avec un acc$([char]0xE8)s restreint ou dans une maison unifamiliale avec un sous-sol encombr$([char]0xE9), notre $([char]0xE9)quipe s'adapte. Nous prot$([char]0xE9)geons vos murs et planchers lors de la manipulation d'objets lourds.",
    "$([char]0xC0) {{CITY_NAME}}, le ramassage d'encombrants peut $([char]0xEA)tre un d$([char]0xE9)fi, surtout avec les horaires stricts des collectes municipales. Ramasse Vite vous lib$([char]0xE8)re de ces contraintes en passant quand VOUS le voulez. Id$([char]0xE9)al pour les r$([char]0xE9)novations ou les d$([char]0xE9)m$([char]0xE9)nagements.",
    "Notre service $([char]0xE0) {{CITY_NAME}} est con$([char]0xE7)u pour $([char]0xEA)tre cl$([char]0xE9) en main. Vous n'avez rien $([char]0xE0) sortir sur le trottoir. Nos techniciens entrent, ramassent, nettoient et partent. Nous desservons tous les quartiers, des zones r$([char]0xE9)sidentielles aux secteurs commerciaux.",
    "L'$([char]0xE9)cologie est au coeur de notre action $([char]0xE0) {{CITY_NAME}}. Nous trions m$([char]0xE9)ticuleusement les mati$([char]0xE8)res dans nos camions pour maximiser le recyclage. Vos vieux meubles et $([char]0xE9)lectros auront une seconde vie ou seront dispos$([char]0xE9)s de mani$([char]0xE8)re $([char]0xE9)cologique.",
    "Particuliers et entreprises de {{CITY_NAME}} font appel $([char]0xE0) nous pour notre rapidit$([char]0xE9). Souvent disponibles le jour m$([char]0xEA)me, nous sommes la solution parfaite pour les urgences. Une $([char]0xE9)quipe forte, polie et efficace $([char]0xE0) votre service.",
    "Acc$([char]0xE8)s difficile ? Escaliers en colima$([char]0xE7)on ? Aucun probl$([char]0xE8)me pour nos experts $([char]0xE0) {{CITY_NAME}}. Nous avons l'$([char]0xE9)quipement et l'exp$([char]0xE9)rience pour sortir les objets les plus volumineux sans rien ab$([char]0xEE)mer. Laissez-nous forcer pour vous."
)

$en_services_paragraphs = @(
    "We understand that every property in {{CITY_NAME}} is unique. Whether you live in a condo with tight access or a detached home with a cluttered basement, our team adapts. We protect your walls and floors while handling heavy items, ensuring a damage-free service.",
    "In {{CITY_NAME}}, getting rid of bulk items can be a hassle given strict municipal schedules. Ramasse Vite frees you from these constraints by coming when YOU need us. Perfect for renovations or moving out.",
    "Our service in {{CITY_NAME}} is fully turnkey. You don't need to drag anything to the curb. Our technicians come in, load up, sweep up, and head out. We serve all neighborhoods, from quiet residential streets to busy commercial hubs.",
    "Eco-friendliness is at the core of what we do in {{CITY_NAME}}. We meticulously sort materials in our trucks to maximize recycling. Your old furniture and appliances will get a second life or be disposed of responsibly.",
    "Homeowners and businesses in {{CITY_NAME}} trust us for our speed. Often available for same-day service, we are the perfect solution for urgent needs. A strong, polite, and efficient team at your service.",
    "Difficult access? Spiral staircases? No problem for our experts in {{CITY_NAME}}. We have the equipment and experience to remove the bulkiest items without damage. Let us do the heavy lifting.",
    "For contractors and busy sites, we offer **live load pickup** services in {{CITY_NAME}}. Our truck waits while you load, or we load it immediately for you."
)

# --- 3. GENERATION LOOP ---

Write-Host "Starting Generation..."

foreach ($row in $data) {
    $city_display = $row.city_display
    $fr_filename = $row.fr_filename
    $en_filename = $row.en_filename
    $kw_fr = $row.primary_kw_fr
    $kw_en = $row.primary_kw_en
    $region = $row.region

    # Random Content
    $fr_unique = $fr_services_paragraphs | Get-Random
    $en_unique = $en_services_paragraphs | Get-Random
    $fr_nearby = Get-Nearby-Links $city_display $region $data 'fr'
    $en_nearby = Get-Nearby-Links $city_display $region $data 'en'

    # ---------------- FR PAGE ----------------
    $fr_html = @"
<!DOCTYPE html>
<html lang="fr-CA" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$kw_fr $([char]0xE0) $city_display | Ramasse Vite Rive-Sud</title>
    <meta name="description" content="Service de d$([char]0xE9)barras rapide et $([char]0xE9)coresponsable $([char]0xE0) $city_display. Meubles, $([char]0xE9)lectros, d$([char]0xE9)bris de r$([char]0xE9)novation. Soumission gratuite.">
    <link rel="canonical" href="https://ramasseviterivesud.com/$fr_filename">
    <meta property="og:title" content="$kw_fr - Service Expert">
    <meta property="og:description" content="D$([char]0xE9)barras cl$([char]0xE9) en main $([char]0xE0) $city_display. On ramasse tout!">
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
        <div class="container text-center" style="position: relative; z-index: 10;">
            <span style="color: var(--rvrs-orange); font-weight: bold; text-transform: uppercase; letter-spacing: 2px;">Service $city_display</span>
            <h1 style="font-size: 3.5rem; margin: 20px 0; line-height: 1.1; color: #ffffff;">Ramassage d'encombrants $([char]0xE0) <span class="text-orange">$city_display</span></h1>
            <p style="font-size: 1.25rem; color: #f0f0f0; margin-bottom: 30px;">Lib$([char]0xE9)rez votre espace sans effort. Nous faisons tout le travail physique.</p>
            
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

    <section class="section" id="services">
        <div class="container">
            <h2 class="text-center">Services de d$([char]0xE9)barras $([char]0xE0) <span class="text-orange">$city_display</span></h2>
            <div style="max-width: 800px; margin: 40px auto; text-align: left; background: #1a1a1a; padding: 30px; border-radius: 8px; border-left: 4px solid var(--rvrs-orange);">
                <p style="font-size: 1.1rem; line-height: 1.8; color: #ddd;">$($fr_unique.Replace("{{CITY_NAME}}", "$city_display"))</p>
                <p style="margin-top: 20px; font-size: 1.1rem; line-height: 1.8; color: #ddd;">Que ce soit pour $([char]0xE9)vacuer des <strong>d$([char]0xE9)bris de r$([char]0xE9)novation</strong>, vider un appartement, ou se d$([char]0xE9)barrasser de vieux meubles, Ramasse Vite Rive-Sud est votre partenaire de confiance $([char]0xE0) $city_display.</p>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container text-center">
            <h2 style="margin-bottom: 40px;">Ce qu'on ramasse $([char]0xE0) $city_display</h2>
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
             
             <!-- Volume Grid (1/8ths) -->
             <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 10px; margin-bottom: 40px;">
                <!-- 1/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">1/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(Minimum)</div>
                </div>
                <!-- 2/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">2/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(1/4 Camion)</div>
                </div>
                <!-- 3/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">3/8</div>
                    <div style="font-size: 0.9rem; color: #888;"></div>
                </div>
                <!-- 4/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">4/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(1/2 Camion)</div>
                </div>
                <!-- 5/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">5/8</div>
                    <div style="font-size: 0.9rem; color: #888;"></div>
                </div>
                <!-- 6/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">6/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(3/4 Camion)</div>
                </div>
                <!-- 7/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">7/8</div>
                    <div style="font-size: 0.9rem; color: #888;"></div>
                </div>
                <!-- 8/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">8/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(Plein)</div>
                </div>
             </div>

             <a href="index.html#prix" class="btn btn-primary">Obtenir mon Prix</a>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center" style="margin-bottom: 40px;">FAQ $([char]0xE0) $city_display</h2>
            <div class="grid" style="grid-template-columns: 1fr 1fr; gap: 30px;">
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                    <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Intervenez-vous partout $([char]0xE0) $city_display?</h3>
                    <p style="font-size: 0.95rem; color: #ccc;">Oui, nous couvrons l'ensemble du territoire de $city_display.</p>
                </div>
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Vos prix incluent-ils les frais d'$([char]0xE9)cocentre?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Absolument. Nos tarifs incluent la main d'oeuvre, le transport, et les frais de recyclage.</p>
                </div>
                 <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Faut-il pr$([char]0xE9)parer les objets?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Non, tant que c'est accessible. Rassemblez les petits objets en bo$([char]0xEE)tes si possible.</p>
                </div>
                 <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Quels d$([char]0xE9)lais pour $city_display?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">Nous visons un service dans les 24 $([char]0xE0) 48h.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container">
            <h3 style="margin-bottom: 20px;">Zones desservies pr$([char]0xE8)s de $city_display</h3>
            <div class="footer-links" style="column-count: 3; column-gap: 20px;">
                $fr_nearby
            </div>
        </div>
    </section>

    <footer class="rvrs-footer">
        <div class="container">
            <div class="rvrs-footer-grid">
                <!-- Col 1: Brand & Mission -->
                <div class="rvrs-footer-col">
                    <a href="index.html" class="flex" style="gap: 10px; margin-bottom: 20px;">
                        <span style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">RVRS</span>
                        <span style="font-size: 1.5rem; font-weight: 700; color: white;">Ramasse Vite</span>
                    </a>
                    <p class="rvrs-footer-mission">Offrir un service de d$([char]0xE9)barras rapide et sans tracas pour tous vos besoins r$([char]0xE9)sidentiels et commerciaux sur la Rive-Sud.</p>
                    <div class="rvrs-footer-socials">
                        <a href="https://www.facebook.com/people/Ramasse-Vite-Rive-Sud/61574551436677/" target="_blank" class="rvrs-footer-social-link"><i class="fa-brands fa-facebook-f"></i></a>
                    </div>
                </div>

                <!-- Col 2: Quick Links -->
                <div class="rvrs-footer-col">
                    <h4>Liens Rapides</h4>
                    <ul class="rvrs-footer-links">
                        <li><a href="index.html">Accueil</a></li>
                        <li><a href="index.html#services">Services</a></li>
                        <li><a href="index.html#prix">Tarifs & Prix</a></li>
                        <li><a href="index.html#zones">Zones Desservies</a></li>
                    </ul>
                </div>

                <!-- Col 3: Services -->
                <div class="rvrs-footer-col">
                    <h4>Services</h4>
                    <ul class="rvrs-footer-links">
                        <li><a href="index.html">Ramassage de Meubles</a></li>
                        <li><a href="index.html">$([char]0xC9)lectrom$([char]0xE9)nagers</a></li>
                        <li><a href="index.html">D$([char]0xE9)bris de Construction</a></li>
                        <li><a href="index.html">Vider Maison / Appart</a></li>
                    </ul>
                </div>

                <!-- Col 4: Contact -->
                <div class="rvrs-footer-col">
                    <h4>Contactez-nous</h4>
                    
                    <div class="rvrs-footer-contact-item">
                        <i class="fa-solid fa-phone rvrs-footer-icon"></i>
                        <div class="rvrs-contact-details">
                            <span class="rvrs-contact-label">T$([char]0xE9)l$([char]0xE9)phone</span>
                            <a href="tel:+14385271701" class="rvrs-contact-value">438 527 1701</a>
                        </div>
                    </div>

                    <div class="rvrs-footer-contact-item">
                        <i class="fa-solid fa-envelope rvrs-footer-icon"></i>
                        <div class="rvrs-contact-details">
                            <span class="rvrs-contact-label">Courriel</span>
                            <a href="mailto:Ramassevite.soumission@outlook.com" class="rvrs-contact-value">Ramassevite.soumission@outlook.com</a>
                        </div>
                    </div>

                     <div class="rvrs-footer-contact-item">
                        <i class="fa-solid fa-clock rvrs-footer-icon"></i>
                        <div class="rvrs-contact-details">
                            <span class="rvrs-contact-label">Heures d'ouverture</span>
                            <span class="rvrs-contact-value" style="font-size: 0.9rem;">Lun-Dim : 7h00 - 19h00</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="rvrs-footer-bottom">
                &copy; 2026 Ramasse Vite Rive-Sud. Tous droits r$([char]0xE9)serv$([char]0xE9)s.
            </div>
        </div>
    </footer>
    <script src="app.js"></script>
</body>
</html>
"@

    # ---------------- EN PAGE ----------------
    $en_html = @"
<!DOCTYPE html>
<html lang="en-CA" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$kw_en in $city_display | Ramasse Vite Rive-Sud</title>
    <meta name="description" content="Fast and eco-friendly junk removal in $city_display. Furniture, appliances, debris. Free quote. Same day or next day service.">
    <link rel="canonical" href="https://ramasseviterivesud.com/$en_filename">
    <meta property="og:title" content="$kw_en - Expert Service">
    <meta property="og:description" content="Turnkey junk removal in $city_display. We take everything!">
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
        <div class="container text-center" style="position: relative; z-index: 10;">
            <span style="color: var(--rvrs-orange); font-weight: bold; text-transform: uppercase; letter-spacing: 2px;">Service $city_display</span>
            <h1 style="font-size: 3.5rem; margin: 20px 0; line-height: 1.1;">Junk Removal in <span class="text-orange">$city_display</span></h1>
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

    <section class="section" id="services">
        <div class="container">
            <h2 class="text-center">Debris Removal Services in <span class="text-orange">$city_display</span></h2>
            <div style="max-width: 800px; margin: 40px auto; text-align: left; background: #1a1a1a; padding: 30px; border-radius: 8px; border-left: 4px solid var(--rvrs-orange);">
                <p style="font-size: 1.1rem; line-height: 1.8; color: #ddd;">$($en_unique.Replace("{{CITY_NAME}}", "$city_display"))</p>
                <p style="margin-top: 20px; font-size: 1.1rem; line-height: 1.8; color: #ddd;">Whether clearing out <strong>renovation debris</strong>, emptying an apartment, or getting rid of old furniture, Ramasse Vite Rive-Sud is your trusted partner in $city_display.</p>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container text-center">
            <h2 style="margin-bottom: 40px;">What We Pick Up in $city_display</h2>
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
                        <li>Live Load Pickup</li>
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
             
             <!-- Volume Grid (1/8ths) -->
             <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 10px; margin-bottom: 40px;">
                <!-- 1/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">1/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(Minimum)</div>
                </div>
                <!-- 2/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">2/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(1/4 Truck)</div>
                </div>
                <!-- 3/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">3/8</div>
                    <div style="font-size: 0.9rem; color: #888;"></div>
                </div>
                <!-- 4/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">4/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(1/2 Truck)</div>
                </div>
                <!-- 5/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">5/8</div>
                    <div style="font-size: 0.9rem; color: #888;"></div>
                </div>
                <!-- 6/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">6/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(3/4 Truck)</div>
                </div>
                <!-- 7/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">7/8</div>
                    <div style="font-size: 0.9rem; color: #888;"></div>
                </div>
                <!-- 8/8 -->
                <div style="background: #111; padding: 15px; border-radius: 8px; border: 1px solid #333;">
                    <div style="font-size: 1.5rem; font-weight: 800; color: white;">8/8</div>
                    <div style="font-size: 0.9rem; color: #888;">(Full)</div>
                </div>
             </div>

             <a href="index-en.html#prix" class="btn btn-primary">Get Your Free Estimate</a>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center" style="margin-bottom: 40px;">FAQ in $city_display</h2>
            <div class="grid" style="grid-template-columns: 1fr 1fr; gap: 30px;">
                <div style="background: #1E1E1E; padding: 20px; border-radius: 8px;">
                    <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">Do you serve all of $city_display?</h3>
                    <p style="font-size: 0.95rem; color: #ccc;">Yes, we cover the entire territory of $city_display.</p>
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
                     <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--rvrs-orange);">How fast can you come to $city_display?</h3>
                     <p style="font-size: 0.95rem; color: #ccc;">We aim for service within 24 to 48 hours.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section bg-card">
        <div class="container">
            <h3 style="margin-bottom: 20px;">Service Areas Near $city_display</h3>
            <div class="footer-links" style="column-count: 3; column-gap: 20px;">
                $en_nearby
            </div>
        </div>
    </section>

    <footer class="rvrs-footer">
        <div class="container">
            <div class="rvrs-footer-grid">
                <!-- Col 1: Brand & Mission -->
                <div class="rvrs-footer-col">
                    <a href="index-en.html" class="flex" style="gap: 10px; margin-bottom: 20px;">
                        <span style="font-size: 1.5rem; font-weight: 800; color: var(--rvrs-orange);">RVRS</span>
                        <span style="font-size: 1.5rem; font-weight: 700; color: white;">Ramasse Vite</span>
                    </a>
                    <p class="rvrs-footer-mission">Providing fast, professional, and hassle-free junk removal service for all your residential and commercial needs on the South Shore.</p>
                    <div class="rvrs-footer-socials">
                        <a href="https://www.facebook.com/people/Ramasse-Vite-Rive-Sud/61574551436677/" target="_blank" class="rvrs-footer-social-link"><i class="fa-brands fa-facebook-f"></i></a>
                    </div>
                </div>

                <!-- Col 2: Quick Links -->
                <div class="rvrs-footer-col">
                    <h4>Quick Links</h4>
                    <ul class="rvrs-footer-links">
                        <li><a href="index-en.html">Home</a></li>
                        <li><a href="index-en.html#services">Services</a></li>
                        <li><a href="index-en.html#pricing">Pricing</a></li>
                        <li><a href="index-en.html#map">Service Areas</a></li>
                    </ul>
                </div>

                <!-- Col 3: Services -->
                <div class="rvrs-footer-col">
                    <h4>Services</h4>
                    <ul class="rvrs-footer-links">
                        <li><a href="index-en.html">Furniture Removal</a></li>
                        <li><a href="index-en.html">Appliances</a></li>
                        <li><a href="index-en.html">Construction Debris</a></li>
                        <li><a href="index-en.html">House Cleanout</a></li>
                    </ul>
                </div>

                <!-- Col 4: Contact -->
                <div class="rvrs-footer-col">
                    <h4>Contact Us</h4>
                    
                    <div class="rvrs-footer-contact-item">
                        <i class="fa-solid fa-phone rvrs-footer-icon"></i>
                        <div class="rvrs-contact-details">
                            <span class="rvrs-contact-label">Phone</span>
                            <a href="tel:+14385271701" class="rvrs-contact-value">438 527 1701</a>
                        </div>
                    </div>

                    <div class="rvrs-footer-contact-item">
                        <i class="fa-solid fa-envelope rvrs-footer-icon"></i>
                        <div class="rvrs-contact-details">
                            <span class="rvrs-contact-label">Email</span>
                            <a href="mailto:Ramassevite.soumission@outlook.com" class="rvrs-contact-value">Ramassevite.soumission@outlook.com</a>
                        </div>
                    </div>

                     <div class="rvrs-footer-contact-item">
                        <i class="fa-solid fa-clock rvrs-footer-icon"></i>
                        <div class="rvrs-contact-details">
                            <span class="rvrs-contact-label">Opening Hours</span>
                            <span class="rvrs-contact-value" style="font-size: 0.9rem;">Mon-Sun : 7am - 7pm</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="rvrs-footer-bottom">
                &copy; 2026 Ramasse Vite Rive-Sud. All rights reserved.
            </div>
        </div>
    </footer>
    <script src="app.js"></script>
</body>
</html>
"@

    # Save Files
    write-host "FILENAME: $fr_filename"
    [System.IO.File]::WriteAllText($PWD.Path + "\" + $fr_filename, $fr_html, [System.Text.Encoding]::UTF8)
    write-host "FILENAME: $en_filename"
    [System.IO.File]::WriteAllText($PWD.Path + "\" + $en_filename, $en_html, [System.Text.Encoding]::UTF8)
}

# --- 4. SUMMARY TABLE ---
Write-Host "`n# City Pages Summary"
Write-Host "city_display | fr_filename | en_filename | primary_kw_fr | primary_kw_en"
Write-Host "---|---|---|---|---"
foreach ($row in $data) {
    Write-Host "$($row.city_display) | $($row.fr_filename) | $($row.en_filename) | $($row.primary_kw_fr) | $($row.primary_kw_en)"
}
