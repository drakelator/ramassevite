# Force UTF-8
$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 1. CONFIGURATION ---
$csvPath = "$PSScriptRoot/cities.csv"
$data = Import-Csv -Path $csvPath

# Define Profiles
$urban_core = @(
    "Montr$([char]0xE9)al", "Ahuntsic", "C$([char]0xF4)te-des-Neiges", "Notre-Dame-de-Gr$([char]0xE2)ce", 
    "Le Plateau-Mont-Royal", "Le Sud-Ouest", "Hochelaga-Maisonneuve", "Outremont", "Verdun", 
    "Ville-Marie", "Villeray", "Saint-Michel", "Parc-Extension", "Westmount", "Griffintown", 
    "Rosemont", "La Petite-Patrie"
)
$suburban_dense = @(
    "Longueuil", "Brossard", "Boucherville", "Saint-Lambert", "Saint-Bruno-de-Montarville", 
    "Saint-Jean-sur-Richelieu", "Ch$([char]0xE2)teauguay", "Sainte-Julie", "Vaudreuil-Dorion", 
    "Lachine", "LaSalle", "Saint-Laurent", "Saint-L$([char]0xE9)onard", "Anjou", "Montr$([char]0xE9)al-Nord",
    "Dollard-des-Ormeaux", "Pointe-Claire", "Kirkland"
)
# Exurban is calculated dynamically from CSV excluding the above

# --- HELPERS ---

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
    $text = $text -replace "'", ""         # Remove apostrophes
    
    $text = $text.Normalize([System.Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder
    foreach ($c in $text.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$builder.Append($c) }
    }
    $slug = $builder.ToString().Normalize([System.Text.NormalizationForm]::FormC).ToLower() -replace '[^a-z0-9\s-]', '' -replace '\s+', '-' -replace '-+', '-'
    return $slug
}

function Get-City-Profile {
    param ($city)
    if ($urban_core -contains $city) { return "URBAN" }
    if ($suburban_dense -contains $city) { return "SUBURBAN" }
    return "EXURBAN"
}

function Get-Nearby-Links {
    param ($currentCity, $regionArray)
    $others = $regionArray | Where-Object { $_ -ne $currentCity } | Get-Random -Count 6
    $links = ""
    foreach ($o in $others) {
        $row = $script:data | Where-Object { $_.city_display -eq $o } | Select-Object -First 1
        if ($row) {
            $links += "<li><a href='$($row.fr_filename)'>$o</a></li>`n"
        }
    }
    return "<ul>$links</ul>"
}

function Get-Nearby-Links-En {
    param ($currentCity, $regionArray)
    $others = $regionArray | Where-Object { $_ -ne $currentCity } | Get-Random -Count 6
    $links = ""
    foreach ($o in $others) {
        $row = $script:data | Where-Object { $_.city_display -eq $o } | Select-Object -First 1
        if ($row) {
            $links += "<li><a href='$($row.en_filename)'>$o</a></li>`n"
        }
    }
    return "<ul>$links</ul>"
}

# --- FAQ GENERATORS ---
$custom_faqs = @{
    "Greenfield Park" = @{
        q1="Quels types de logements utilisent le service de ramassage $([char]0xE0) Greenfield Park ?"
        a1="$([char]0xC0) Greenfield Park, le service est largement utilis$([char]0xE9) par des duplex, triplex, logements locatifs et maisons unifamiliales."
        q2="Pourquoi les r$([char]0xE9)sidents de Greenfield Park font-ils appel $([char]0xE0) nous ?"
        a2="Les demandes sont souvent li$([char]0xE9)es aux d$([char]0xE9)m$([char]0xE9)nagements, aux changements de locataires ou aux r$([char]0xE9)novations."
        q3="Le service est-il adapt$([char]0xE9) aux r$([char]0xE8)glements de Greenfield Park ?"
        a3="Oui. Nous respectons les consignes municipales et d$([char]0xE9)barrassons rapidement sans encombrer la voie publique."
    }
}

function Get-FAQ-Content-FR {
    param ($city, $profile)
    # Defaults
    if ($profile -eq "URBAN") {
        $q1 = "$([char]0xC0) quels types de propri$([char]0xE9)t$([char]0xE9)s s'adresse votre service $([char]0xE0) $city ?"
        $a1 = "$([char]0xC0) $city, nous intervenons principalement dans des <strong>appartements, condos et plex</strong>."
        $q2 = "Dans quelles situations les r$([char]0xE9)sidents de $city nous appellent-ils ?"
        $a2 = "Souvent lors des d$([char]0xE9)m$([char]0xE9)nagements ou pour le d$([char]0xE9)sencombrement avant la vente d'un condo."
        $q3 = "G$([char]0xE9)rez-vous les acc$([char]0xE8)s difficiles $([char]0xE0) $city ?"
        $a3 = "Absolument. Nous sommes habitu$([char]0xE9)s aux escaliers et acc$([char]0xE8)s restreints de $city."
    } elseif ($profile -eq "SUBURBAN") {
        $q1 = "Quels types de r$([char]0xE9)sidences desservez-vous $([char]0xE0) $city ?"
        $a1 = "Nous desservons une majorit$([char]0xE9) de <strong>maisons unifamiliales et de condos</strong> $([char]0xE0) $city."
        $q2 = "Pourquoi utiliser votre service $([char]0xE0) $city ?"
        $a2 = "Pour r$([char]0xE9)cup$([char]0xE9)rer de l'espace dans le garage ou apr$([char]0xE8)s des r$([char]0xE9)novations."
        $q3 = "Dois-je mettre les objets sur le bord de la rue $([char]0xE0) $city ?"
        $a3 = "Non! Nous venons chercher les objets <strong>o$([char]0xF9) ils se trouvent</strong>."
    } else {
        $q1 = "Intervenez-vous sur les grands terrains $([char]0xE0) $city ?"
        $a1 = "Oui, $([char]0xE0) $city, nous intervenons souvent sur des <strong>propri$([char]0xE9)t$([char]0xE9)s avec grands terrains</strong> et garages."
        $q2 = "Quels sont les besoins fr$([char]0xE9)quents $([char]0xE0) $city ?"
        $a2 = "Nettoyage de printemps, vider des granges ou cabanons, et d$([char]0xE9)bris de construction."
        $q3 = "Le service couvre-t-il les zones rurales de $city ?"
        $a3 = "Oui, nous couvrons tout le territoire, m$([char]0xEA)me les zones plus $fast$([char]0xE9)loign$([char]0xE9)es."
    }
    $q4 = "Quels sont vos d$([char]0xE9)lais d'intervention $([char]0xE0) $city ?"
    $a4 = "Souvent <strong>le jour m$([char]0xEA)me ou le lendemain</strong>."
    
    # Custom Override
    if ($custom_faqs.ContainsKey($city)) {
        $c = $custom_faqs[$city]
        $q1=$c.q1; $a1=$c.a1
        $q2=$c.q2; $a2=$c.a2
        $q3=$c.q3; $a3=$c.a3
    }
    
    return @"
    <div style="max-width: 800px; margin: 0 auto;">
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q1 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a1</p>
        </details>
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q2 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a2</p>
        </details>
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q3 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a3</p>
        </details>
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q4 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a4</p>
        </details>
    </div>
"@
}

function Get-FAQ-Content-EN {
    param ($city, $profile)
    if ($profile -eq "URBAN") {
        $q1 = "What types of properties do you service in ${city}?"
        $a1 = "In $city, we mostly serve <strong>apartments, condos, and duplexes</strong>."
        $q2 = "When do residents of $city usually call you?"
        $a2 = "Often during moving season, decluttering before selling, or renovations."
        $q3 = "Do you handle difficult access in ${city}?"
        $a3 = "Yes. We are experienced with stairs, elevators, and narrow alleys in $city."
    } elseif ($profile -eq "SUBURBAN") {
        $q1 = "What kind of homes do you pick up from in ${city}?"
        $a1 = "We primarily serve <strong>single-family homes and townhouses</strong> in $city."
        $q2 = "Why use your service in $city?"
        $a2 = "$city residents often call us to reclaim garage space or after renovations."
        $q3 = "Should I leave items on the curb in $city?"
        $a3 = "No! We pick up items <strong>where they are</strong> (inside, backyard, garage)."
    } else {
        $q1 = "Do you service large properties in ${city}?"
        $a1 = "Yes, in $city, we often work on <strong>larger properties with sheds and barns</strong>."
        $q2 = "What are common needs in $city?"
        $a2 = "Spring cleaning, clearing out barns/sheds, and removing construction debris."
        $q3 = "Do you cover the rural areas of $city?"
        $a3 = "Yes, we cover the entire territory."
    }
    
    return @"
    <div style="max-width: 800px; margin: 0 auto;">
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q1 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a1</p>
        </details>
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q2 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a2</p>
        </details>
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">$q3 <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">$a3</p>
        </details>
        <details style="background: #1E1E1E; padding: 20px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;">
            <summary style="font-weight: 700; font-size: 1.1rem; list-style: none; display: flex; justify-content: space-between; align-items: center;">How fast can you come to ${city}? <i class="fa-solid fa-plus text-orange"></i></summary>
            <p style="margin-top: 15px; margin-bottom: 0; color: #ccc;">Often <strong>same-day or next-day service</strong>.</p>
        </details>
    </div>
"@
}

# --- 3. GENERATION LOOP ---
$sitemap_urls = @(
    "https://ramasseviterivesud.com/", "https://ramasseviterivesud.com/index.html", "https://ramasseviterivesud.com/index-en.html",
    "https://ramasseviterivesud.com/about.html", "https://ramasseviterivesud.com/about-en.html",
    "https://ramasseviterivesud.com/service-residentiel.html", "https://ramasseviterivesud.com/service-residential.html",
    "https://ramasseviterivesud.com/service-debris-renovation.html", "https://ramasseviterivesud.com/service-construction-debris.html",
    "https://ramasseviterivesud.com/service-debarras-commercial.html", "https://ramasseviterivesud.com/service-commercial-junk.html",
    "https://ramasseviterivesud.com/projects.html", "https://ramasseviterivesud.com/projets.html",
    "https://ramasseviterivesud.com/service-gestion-immobiliere.html", "https://ramasseviterivesud.com/service-property-management.html",
    "https://ramasseviterivesud.com/service-vide-maison.html", "https://ramasseviterivesud.com/service-vide-garage.html",
    "https://ramasseviterivesud.com/service-succession.html"
)

$fr_services_paragraphs = @(
    "Nous comprenons que chaque propri$([char]0xE9)t$([char]0xE9) $([char]0xE0) {{CITY_NAME}} a ses particularit$([char]0xE9)s. Notre $([char]0xE9)quipe s'adapte.",
    "Ramasse Vite vous lib$([char]0xE8)re des contraintes des collectes municipales $([char]0xE0) {{CITY_NAME}}.",
    "Notre service $([char]0xE0) {{CITY_NAME}} est 100% cl$([char]0xE9) en main.",
    "L'$([char]0xE9)cologie est importante $([char]0xE0) {{CITY_NAME}}. Nous trions m$([char]0xE9)ticuleusement."
)
$en_services_paragraphs = @(
    "We understand that every property in {{CITY_NAME}} is unique.",
    "Ramasse Vite frees you from strict municipal schedules in {{CITY_NAME}}.",
    "Our service in {{CITY_NAME}} is fully turnkey.",
    "We prioritize eco-friendly disposal in {{CITY_NAME}}."
)

$fr_footer_html = @"
    <footer class="rvrs-footer">
        <div class="container">
            <div class="rvrs-footer-grid">
                <!-- Col 1: Brand & Mission -->
                <div class="rvrs-footer-col">
                    <a href="index.html" class="flex" style="gap: 10px; margin-bottom: 20px;">
                        <img src="images/logo.png" alt="RVRS Logo" style="height: 50px; width: auto;">
                        <div style="line-height: 1;">
                            <span style="display: block; font-size: 1.1rem; font-weight: 700; color: white;">Ramasse Vite</span>
                        </div>
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
                        <li><a href="index.html#map">Zones Desservies</a></li>
                    </ul>
                </div>

                <!-- Col 3: Services -->
                <div class="rvrs-footer-col">
                    <h4>Services</h4>
                    <ul class="rvrs-footer-links">
                        <li><a href="service-residentiel.html">Ramassage de Meubles</a></li>
                        <li><a href="service-vide-maison.html">Vide Maison Complet</a></li>
                        <li><a href="service-vide-garage.html">Vide Garage & Cabanon</a></li>
                        <li><a href="service-succession.html">Succession</a></li>
                        <li><a href="service-debris-renovation.html">D$([char]0xE9)bris de Construction</a></li>
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
                            <span class="rvrs-contact-value" style="font-size: 0.9rem;">Lun-Sam : 7h00 - 17h00<br>Dim : 12h00 - 17h00</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="rvrs-footer-bottom">
                &copy; 2026 Ramasse Vite Rive-Sud. Tous droits r$([char]0xE9)serv$([char]0xE9)s.
            </div>
        </div>
    </footer>
"@

$en_footer_html = @"
    <footer class="rvrs-footer">
        <div class="container">
            <div class="rvrs-footer-grid">
                <!-- Col 1: Brand & Mission -->
                <div class="rvrs-footer-col">
                    <a href="index-en.html" class="flex" style="gap: 10px; margin-bottom: 20px;">
                        <img src="images/logo.png" alt="RVRS Logo" style="height: 50px; width: auto;">
                        <div style="line-height: 1;">
                            <span style="display: block; font-size: 1.1rem; font-weight: 700; color: white;">Ramasse Vite</span>
                        </div>
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
                        <li><a href="service-residential.html">Furniture Removal</a></li>
                        <li><a href="service-residential.html#appliances">Appliances</a></li>
                        <li><a href="service-construction-debris.html">Construction Debris</a></li>
                        <li><a href="service-commercial-junk.html">Commercial Service</a></li>
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
                            <span class="rvrs-contact-value" style="font-size: 0.9rem;">Mon-Sat : 7am - 5pm<br>Sun : 12pm - 5pm</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="rvrs-footer-bottom">
                &copy; 2026 Ramasse Vite Rive-Sud. All rights reserved.
            </div>
        </div>
    </footer>
"@

# Calculate Exurban
$all_csv_cities = $data.city_display
$exurban = @()
foreach ($c in $all_csv_cities) {
    if ($urban_core -notcontains $c -and $suburban_dense -notcontains $c) { $exurban += $c }
}

Write-Host "Starting Generation..."

foreach ($row in $data) {
    $city = $row.city_display
    if ([string]::IsNullOrWhiteSpace($city)) { continue }
    
    $fr_filename = $row.fr_filename
    $en_filename = $row.en_filename
    $kw_fr = $row.primary_kw_fr
    $kw_en = $row.primary_kw_en
    $slug = $row.slug
    
    $profile = Get-City-Profile $city
    if ($urban_core -contains $city) { $region = $urban_core }
    elseif ($suburban_dense -contains $city) { $region = $suburban_dense }
    else { $region = $exurban }

    $fr_unique = $fr_services_paragraphs | Get-Random
    $en_unique = $en_services_paragraphs | Get-Random
    $fr_nearby = Get-Nearby-Links $city $region
    $en_nearby = Get-Nearby-Links-En $city $region
    
    $fr_faq = Get-FAQ-Content-FR $city $profile
    $en_faq = Get-FAQ-Content-EN $city $profile

    $sitemap_urls += "https://ramasseviterivesud.com/$fr_filename"
    $sitemap_urls += "https://ramasseviterivesud.com/$en_filename"

    # Gallery
    $img_residential = @(@{src="images/gallery-cleanout.jpg"; altFr="Exemple de vide maison"; altEn="House cleanout example"},@{src="images/hoarding-1.jpg"; altFr="Nettoyage syndrome de Diogène"; altEn="Hoarding cleanup service"},@{src="images/hoarding-2.jpg"; altFr="Débarras extrême et insalubrité"; altEn="Extreme clutter removal"},@{src="images/hoarding-3.jpg"; altFr="Vide maison encombré"; altEn="Cluttered house cleanout"},@{src="images/hoarding-kitchen.jpg"; altFr="Vide cuisine encombrée"; altEn="Cluttered kitchen cleanout"})
    $img_construction = @(@{src="images/gallery-debris.jpg"; altFr="Ramassage de débris de construction"; altEn="Construction debris removal"},@{src="images/construction-wood.jpg"; altFr="Ramassage de bois et matériaux"; altEn="Wood and material pickup"},@{src="images/construction-wood-2.jpg"; altFr="Ramassage de bois de construction"; altEn="Construction wood debris removal"},@{src="images/construction-scaffold.jpg"; altFr="Chantier et échafaudages"; altEn="Construction site cleanup"},@{src="images/concrete-slab.jpg"; altFr="Démolition de dalle de béton"; altEn="Concrete slab removal"})
    $img_variety = @(@{src="images/gallery-spa.jpg"; altFr="Enlèvement de spa et jacuzzi"; altEn="Hot tub and spa removal"},@{src="images/truck-night.jpg"; altFr="Camion de ramassage en action"; altEn="Junk removal truck in action"})
    
    $sel_res = $img_residential | Get-Random
    $sel_const = $img_construction | Get-Random
    $sel_var = $img_variety | Get-Random
    $selected_gallery = @($sel_res, $sel_const, $sel_var)
    $fr_gallery_html = ""; $en_gallery_html = ""
    foreach ($img in $selected_gallery) {
        $fr_gallery_html += "<div style='height: 250px; border-radius: 12px; overflow: hidden; border: 1px solid #333;'><img src='$($img.src)' alt='$($img.altFr)' style='width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;' onmouseover='this.style.transform=`scale(1.05)`' onmouseout='this.style.transform=`scale(1)`'></div>"
        $en_gallery_html += "<div style='height: 250px; border-radius: 12px; overflow: hidden; border: 1px solid #333;'><img src='$($img.src)' alt='$($img.altEn)' style='width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;' onmouseover='this.style.transform=`scale(1.05)`' onmouseout='this.style.transform=`scale(1)`'></div>"
    }

    $fr_html = @"
<!DOCTYPE html>
<html lang="fr-CA" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ramassage d'Encombrants $([char]0xE0) $city (Service 24h) | Ramasse Vite</title>
    <meta name="description" content="Besoin d'un rammassage $([char]0xE0) $city? Nous ramassons tout. Service rapide (24h) et prix fixe.">
    <link rel="canonical" href="https://ramasseviterivesud.com/$fr_filename">
    <link rel="icon" type="image/png" href="images/favicon.png">
    <link rel="apple-touch-icon" href="images/favicon.png">
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
                    <li class="dropdown">
                        <a href="index.html#services" class="dropbtn">Services <i class="fa-solid fa-chevron-down" style="font-size: 0.8em; margin-left: 5px;"></i></a>
                        <div class="dropdown-content">
                            <a href="service-residentiel.html">R$([char]0xE9)sidentiel</a>
                            <a href="service-debris-renovation.html">D$([char]0xE9)bris de Construction</a>
                            <a href="service-debarras-commercial.html">Commercial</a>
                        </div>
                    </li>
                    <li><a href="index.html#map">Zones</a></li>
                    <li><a href="index.html#prix">Prix</a></li>
                </ul>
            </nav>
            <div class="flex">
                <a href="$en_filename" style="color: white; font-weight: 700; margin-right: 15px;">EN</a>
                <a href="tel:+14385271701" class="btn btn-primary" style="background: var(--rvrs-orange); color: white; padding: 12px 24px; font-weight: 700; border-radius: 50px;"><i class="fa-solid fa-phone" style="margin-right: 8px;"></i> 438 527 1701</a>
                <button class="mobile-toggle"><i class="fa-solid fa-bars"></i></button>
            </div>
        </div>
    </header>

    <section class="hero" style="padding-top: 150px; min-height: 80vh; display: flex; align-items: center;">
        <div class="container text-center">
            <span style="color: var(--rvrs-orange); font-weight: bold; text-transform: uppercase; letter-spacing: 2px;">Service $city</span>
            <h1 style="font-size: clamp(2.5rem, 5vw, 4.5rem); margin: 20px 0; line-height: 1.1;">Ramassage d'encombrants $([char]0xE0) <span class="text-orange">$city</span></h1>
            <p style="font-size: 1.25rem; color: #ddd; margin-bottom: 30px;">Lib$([char]0xE9)rez votre espace sans effort.</p>
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

    <section class="section text-center">
        <div class="container">
            <h2 style="margin-top: 20px;"><span style="background: var(--rvrs-orange); color: black; padding: 0 10px;">Comment $([char]0xE7)a marche?</span></h2>
            <div class="steps-grid" style="text-align: left;">
                <div class="step-item reveal-hidden">
                    <h3><div class="step-number">1</div> Contactez-nous</h3>
                    <p>Appelez-nous au <span class="text-orange">438 527 1701</span> ou remplissez notre formulaire.</p>
                </div>
                <div class="step-item reveal-hidden stagger-1">
                    <h3><div class="step-number">2</div> Nous Estimons</h3>
                    <p>Nous vous donnons le prix le plus comp$([char]0xE9)titif et raisonnable.</p>
                </div>
                <div class="step-item reveal-hidden stagger-2">
                    <h3><div class="step-number">3</div> Nous Ramassons</h3>
                    <p>Nous venons faire le travail!</p>
                </div>
                <div class="step-item reveal-hidden stagger-3">
                    <h3><div class="step-number">4</div> Suivi Client $([char]0xD83D)$([char]0xDE09)</h3>
                    <p>Votre satisfaction est notre priorit$([char]0xE9).</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container text-center">
             <h2 style="margin-bottom: 20px;">Nos Prix</h2>
             <p>Nos tarifs sont bas$([char]0xE9)s sur le volume.</p>
             <a href="index.html#prix" class="btn btn-primary">Obtenez votre estimation gratuite</a>
        </div>
    </section>
    
    <section class="section" style="background: #050505;">
        <div class="container">
            <h2 class="text-center" style="margin-bottom: 40px;">FAQ - Service de ramassage $([char]0xE0) $city</h2>
            $fr_faq
        </div>
    </section>


    
$fr_footer_html
    <script src="app.js"></script>
    <script>
    {
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "LocalBusiness",
          "name": "Ramasse Vite - $city",
          "telephone": "+14385271701",
          "url": "https://ramasseviterivesud.com/$fr_filename",
          "image": "https://ramasseviterivesud.com/images/logo.png",
          "address": {"@type": "PostalAddress", "addressLocality": "$city", "addressRegion": "QC", "addressCountry": "CA"},
          "priceRange": "$$",
          "areaServed": { "@type": "City", "name": "$city" }
        },
        {
          "@type": "Service",
          "name": "Ramassage d'encombrants $([char]0xE0) $city",
          "provider": { "@id": "https://ramasseviterivesud.com/$fr_filename#localbusiness" },
          "description": "Service complet de d$([char]0xE9)barras de meubles et d$([char]0xE9)bris $([char]0xE0) $city.",
          "areaServed": { "@type": "City", "name": "$city" }
        },
        {
          "@type": "FAQPage",
          "mainEntity": []
        }
      ]
    }
    </script>
    <!-- Cookie Consent (Law 25) -->
    <link rel="stylesheet" href="cookie-consent.css">
    <script src="cookie-consent.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
             CookieManager.init();
        });
    </script>
</body>
</html>
"@

    $en_html = @"
<!DOCTYPE html>
<html lang="en-CA" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Junk Removal in $city (Same Day) | Ramasse Vite</title>
    <meta name="description" content="Need a pickup in $city? We take everything. Fast service (24h).">
    <link rel="canonical" href="https://ramasseviterivesud.com/$en_filename">
    <link rel="icon" type="image/png" href="images/favicon.png">
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
                    <li class="dropdown">
                        <a href="index-en.html#services" class="dropbtn">Services <i class="fa-solid fa-chevron-down" style="font-size: 0.8em; margin-left: 5px;"></i></a>
                        <div class="dropdown-content">
                            <a href="service-residential.html">Residential</a>
                            <a href="service-debris-renovation.html">Construction Debris</a>
                            <a href="service-debarras-commercial.html">Commercial</a>
                        </div>
                    </li>
                    <li><a href="index-en.html#map">Areas</a></li>
                    <li><a href="index-en.html#prix">Pricing</a></li>
                </ul>
            </nav>
            <div class="flex">
                <a href="$fr_filename" style="color: white; font-weight: 700; margin-right: 15px;">FR</a>
                <a href="tel:+14385271701" class="btn btn-primary" style="background: var(--rvrs-orange); color: white; padding: 12px 24px; font-weight: 700; border-radius: 50px;"><i class="fa-solid fa-phone" style="margin-right: 8px;"></i> 438 527 1701</a>
                <button class="mobile-toggle"><i class="fa-solid fa-bars"></i></button>
            </div>
        </div>
    </header>

    <section class="hero" style="padding-top: 150px; min-height: 80vh; display: flex; align-items: center;">
        <div class="container text-center">
            <span style="color: var(--rvrs-orange); font-weight: bold; text-transform: uppercase; letter-spacing: 2px;">Service $city</span>
            <h1 style="font-size: clamp(2.5rem, 5vw, 4.5rem); margin: 20px 0; line-height: 1.1;">Junk Removal in <span class="text-orange">$city</span></h1>
            <p style="font-size: 1.25rem; color: #ddd; margin-bottom: 30px;">Clear your space effortlessly.</p>
            <div class="flex" style="justify-content: center; gap: 20px; flex-wrap: wrap;">
                <a href="tel:+14385271701" class="btn btn-primary" style="padding: 15px 30px; font-size: 1.1rem;"><i class="fa-solid fa-phone"></i> 438 527 1701</a>
                <a href="index-en.html#prix" class="btn btn-outline" style="padding: 15px 30px; font-size: 1.1rem;">Get a Quote</a>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <h2 class="text-center">Services in <span class="text-orange">$city</span></h2>
            <div style="max-width: 800px; margin: 40px auto; text-align: left; background: #1a1a1a; padding: 30px; border-radius: 8px; border-left: 4px solid var(--rvrs-orange);">
                <p style="font-size: 1.1rem; line-height: 1.8; color: #ddd;">$($en_unique.Replace("{{CITY_NAME}}", "$city"))</p>
                <p style="margin-top: 20px; font-size: 1.1rem; line-height: 1.8; color: #ddd;">Whether clearing out <strong>renovation debris</strong>, emptying an apartment, or getting rid of old furniture, Ramasse Vite Rive-Sud is your trusted partner in $city.</p>
            </div>
        </div>
    </section>

    <section class="section text-center">
        <div class="container">
            <h2 style="margin-top: 20px;"><span style="background: var(--rvrs-orange); color: black; padding: 0 10px;">How It Works?</span></h2>
            <div class="steps-grid" style="text-align: left;">
                <div class="step-item reveal-hidden">
                    <h3><div class="step-number">1</div> Contact Us</h3>
                    <p>Call us at <span class="text-orange">438 527 1701</span> or fill out our quote form.</p>
                </div>
                <div class="step-item reveal-hidden stagger-1">
                    <h3><div class="step-number">2</div> We Estimate</h3>
                    <p>We ensure to give you the most competitive and reasonable price on the market.</p>
                </div>
                <div class="step-item reveal-hidden stagger-2">
                    <h3><div class="step-number">3</div> We Pick Up</h3>
                    <p>We come and do the work!</p>
                </div>
                <div class="step-item reveal-hidden stagger-3">
                    <h3><div class="step-number">4</div> Customer Follow-up $([char]0xD83D)$([char]0xDE09)</h3>
                    <p>Your satisfaction is our priority.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container text-center">
             <h2 style="margin-bottom: 20px;">Our Pricing</h2>
             <p>Our rates are based on volume.</p>
             <a href="index-en.html#prix" class="btn btn-primary">Get Your Free Estimate</a>
        </div>
    </section>
    
    <section class="section" style="background: #050505;">
        <div class="container">
            <h2 class="text-center" style="margin-bottom: 40px;">FAQ - Junk Removal in $city</h2>
            $en_faq
        </div>
    </section>


    
$en_footer_html
    <script src="app.js"></script>
    <script>
    {
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "LocalBusiness",
          "name": "Ramasse Vite - $city",
          "telephone": "+14385271701",
          "url": "https://ramasseviterivesud.com/$en_filename",
          "image": "https://ramasseviterivesud.com/images/logo.png",
          "address": {"@type": "PostalAddress", "addressLocality": "$city", "addressRegion": "QC", "addressCountry": "CA"},
          "priceRange": "$$",
          "areaServed": { "@type": "City", "name": "$city" }
        },
        {
          "@type": "Service",
          "name": "Junk Removal in $city",
          "provider": { "@id": "https://ramasseviterivesud.com/$en_filename#localbusiness" },
          "description": "Full service junk removal regarding furniture and debris in $city.",
          "areaServed": { "@type": "City", "name": "$city" }
        },
        {
          "@type": "FAQPage",
          "mainEntity": []
        }
      ]
    }
    </script>
    <!-- Cookie Consent (Law 25) -->
    <link rel="stylesheet" href="cookie-consent.css">
    <script src="cookie-consent.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
             CookieManager.init();
        });
    </script>
</body>
</html>
"@

    [System.IO.File]::WriteAllText($PWD.Path + "\" + $fr_filename, $fr_html, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($PWD.Path + "\" + $en_filename, $en_html, [System.Text.Encoding]::UTF8)
}

# --- 4. GENERATE SITEMAP ---
$sitemap_content = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
"@
foreach ($url in $sitemap_urls) {
    if ($url -like "*index*") { $prio = "1.0" } else { $prio = "0.8" }
    $sitemap_content += @"
    <url>
        <loc>$url</loc>
        <lastmod>$(Get-Date -Format "yyyy-MM-dd")</lastmod>
        <priority>$prio</priority>
    </url>
"@
}
$sitemap_content += "</urlset>"
[System.IO.File]::WriteAllText($PWD.Path + "\sitemap.xml", $sitemap_content, [System.Text.Encoding]::UTF8)
Write-Host "Generated sitemap.xml with $($sitemap_urls.Count) URLs."
