// Cookie Consent Manager for Law 25
const CookieManager = {
    storageKey: 'rvrs_cookie_consent',
    scriptsToLoad: [], // Scripts that require consent

    init: function () {
        if (!localStorage.getItem(this.storageKey)) {
            this.showBanner();
        } else {
            const consent = JSON.parse(localStorage.getItem(this.storageKey));
            if (consent.analytics) {
                this.loadScripts();
            }
        }
    },

    registerScript: function (scriptSrc, id = null) {
        this.scriptsToLoad.push({ src: scriptSrc, id: id });
    },

    showBanner: function () {
        // Create Banner HTML
        const banner = document.createElement('div');
        banner.id = 'cookie-consent-banner';

        // Detect Language (simple check based on html lang)
        const isEn = document.documentElement.lang.startsWith('en');

        const texts = {
            title: isEn ? "Privacy & Cookies" : "Confidentialité & Cookies",
            desc: isEn
                ? "We use cookies to improve your experience and analyze traffic. By clicking 'Accept', you consent to our tracking methods."
                : "Nous utilisons des cookies pour améliorer votre expérience et analyser le trafic. En cliquant sur 'Accepter', vous consentez à nos méthodes de suivi.",
            accept: isEn ? "Accept" : "Accepter",
            decline: isEn ? "Decline" : "Refuser"
        };

        banner.innerHTML = `
            <div class="cookie-content">
                <div class="cookie-text">
                    <h3>${texts.title} 🍪</h3>
                    <p>${texts.desc}</p>
                </div>
                <div class="cookie-actions">
                    <button id="cookie-decline" class="cookie-btn decline">${texts.decline}</button>
                    <button id="cookie-accept" class="cookie-btn accept">${texts.accept}</button>
                </div>
            </div>
        `;

        document.body.appendChild(banner);

        // Animate in
        setTimeout(() => banner.classList.add('visible'), 100);

        // Listeners
        document.getElementById('cookie-accept').addEventListener('click', () => {
            this.setConsent(true);
            this.hideBanner(banner);
        });

        document.getElementById('cookie-decline').addEventListener('click', () => {
            this.setConsent(false);
            this.hideBanner(banner);
        });
    },

    hideBanner: function (banner) {
        banner.classList.remove('visible');
        setTimeout(() => banner.remove(), 500);
    },

    setConsent: function (granted) {
        const consentData = {
            necessary: true, // Always true
            analytics: granted,
            timestamp: new Date().toISOString()
        };
        localStorage.setItem(this.storageKey, JSON.stringify(consentData));

        if (granted) {
            this.loadScripts();
        }
    },

    loadScripts: function () {
        console.log('🍪 Consent granted. Loading tracking scripts...');
        this.scriptsToLoad.forEach(script => {
            // Avoid duplicates
            if (script.id && document.getElementById(script.id)) return;

            const s = document.createElement('script');
            s.src = script.src;
            s.async = true;
            if (script.id) s.id = script.id;
            document.head.appendChild(s);
        });
    }
};

// Auto-init removed to allow manual control in HTML

