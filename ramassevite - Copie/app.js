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

        let isDragging = false;

        const startDrag = () => isDragging = true;
        const stopDrag = () => isDragging = false;

        const move = (e) => {
            if (!isDragging) return;

            let clientX = e.clientX || e.touches[0].clientX;
            let rect = slider.getBoundingClientRect();
            let x = clientX - rect.left;

            // Constraints
            if (x < 0) x = 0;
            if (x > rect.width) x = rect.width;

            let percentage = (x / rect.width) * 100;

            resize.style.width = percentage + '%';
            handle.style.left = percentage + '%';
        };

        // Mouse Events
        slider.addEventListener('mousedown', startDrag);
        window.addEventListener('mouseup', stopDrag);
        slider.addEventListener('mousemove', move);

        // Touch Events
        slider.addEventListener('touchstart', startDrag);
        window.addEventListener('touchend', stopDrag);
        slider.addEventListener('touchmove', move);

        // Click to jump
        slider.addEventListener('click', (e) => {
            let rect = slider.getBoundingClientRect();
            let x = e.clientX - rect.left;
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
});

// Smooth Scroll handled by CSS (scroll-behavior: smooth)
