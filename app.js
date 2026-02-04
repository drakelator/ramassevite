document.addEventListener('DOMContentLoaded', () => {
    console.log('RVRS RamasseVite Ready 🚛');

    // Scroll Reveal Animations on Scroll
    function reveal() {
        var reveals = document.querySelectorAll(".reveal-hidden");

        for (var i = 0; i < reveals.length; i++) {
            var windowHeight = window.innerHeight;
            var elementTop = reveals[i].getBoundingClientRect().top;
            var elementVisible = 100; // Lower threshold to trigger earlier

            if (elementTop < windowHeight - elementVisible) {
                reveals[i].classList.add("active");
            } else {
                // Optional: remove active class to re-animate (disabled for better UX)
                // reveals[i].classList.remove("active"); 
                // Ensure visible even if logic fails for some reason
                if (windowHeight === 0) reveals[i].classList.add("active");
            }
        }
    }

    window.addEventListener("scroll", reveal);
    reveal(); // Trigger once on load

    // Before/After Slider Logic
    const sliders = document.querySelectorAll('.ba-slider');

    sliders.forEach(slider => {
        const resize = slider.querySelector('.resize');
        const resizeImg = resize.querySelector('img'); // The "Before" image
        const handle = slider.querySelector('.handle');

        // Force image width to match container (Fix for aspect ratio issues)
        function syncImageWidth() {
            if (resizeImg) {
                resizeImg.style.width = slider.offsetWidth + 'px';
                resizeImg.style.maxWidth = 'none'; // Ensure it's not constrained
            }
        }

        // Initial Sync
        syncImageWidth();
        window.addEventListener('resize', syncImageWidth);

        // Init at 50%
        resize.style.width = '50%';
        handle.style.left = '50%';

        // Hover & Touch Logic
        const move = (e) => {
            // For touch, we need to ensure we are 'dragging' or it's just a move?
            // User requested Hover. Touch devices don't hover, so they need drag/touchmove.

            let clientX;

            if (e.type === 'mousemove' || e.type === 'mouseenter') {
                clientX = e.clientX;
            } else if (e.type === 'touchmove') {
                clientX = e.touches[0].clientX;
            } else {
                return;
            }

            let rect = slider.getBoundingClientRect();
            let x = clientX - rect.left;

            // Constraints
            if (x < 0) x = 0;
            if (x > rect.width) x = rect.width;

            let percentage = (x / rect.width) * 100;

            resize.style.width = percentage + '%';
            handle.style.left = percentage + '%';
        };

        // Desktop: Hover (no click needed)
        slider.addEventListener('mousemove', move);
        slider.addEventListener('mouseenter', move);
        slider.addEventListener('mouseleave', () => {
            // Optional: Reset to 50% or keep last position? 
            // Keeping last position is usually less jarring.
        });

        // Mobile: Touch Drag
        slider.addEventListener('touchmove', move);

        // Mobile: Tap to jump
        slider.addEventListener('touchstart', (e) => {
            let rect = slider.getBoundingClientRect();
            let x = e.touches[0].clientX - rect.left;
            let percentage = (x / rect.width) * 100;
            resize.style.width = percentage + '%';
            handle.style.left = percentage + '%';
        });
    });
    // Mobile Menu Toggle
    const mobileToggle = document.querySelector('.mobile-toggle');
    const navMenu = document.querySelector('nav ul');

    if (mobileToggle && navMenu) {
        mobileToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');

            // Toggle Icon (Bars <-> Times)
            const icon = mobileToggle.querySelector('i');
            if (navMenu.classList.contains('active')) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });

        // Close menu when clicking a link
        navMenu.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('active');
                mobileToggle.querySelector('i').classList.remove('fa-times');
                mobileToggle.querySelector('i').classList.add('fa-bars');
            });
        });
    }

    // Mobile City Accordion Logic
    const cityHeaders = document.querySelectorAll('.city-accordion .city-header');

    cityHeaders.forEach(header => {
        header.addEventListener('click', () => {
            const parent = header.parentElement;

            // Close other accordions (optional - creates a true accordion effect)
            // document.querySelectorAll('.city-accordion').forEach(item => {
            //     if (item !== parent) item.classList.remove('active');
            //     if (item !== parent) item.querySelector('.city-header').classList.remove('active');
            // });

            // Toggle current
            parent.classList.toggle('active');
            header.classList.toggle('active');
        });
    });
});

// Smooth Scroll handled by CSS (scroll-behavior: smooth)
