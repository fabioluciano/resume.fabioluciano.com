/**
 * Table of Contents Scroll Spy
 * Highlights the current section in the floating TOC navigation
 */
document.addEventListener("DOMContentLoaded", function () {
  const tocLinks = document.querySelectorAll("#toc a");
  if (!tocLinks.length) return;

  const sectionIds = [
    "summary-title",
    "experience-title",
    "education-title",
    "certs-title",
    "skills-title",
    "languages-title",
    "projects-title",
    "publications-title",
  ];

  // Get all section elements
  const sections = sectionIds
    .map((id) => document.getElementById(id))
    .filter((el) => el !== null);

  if (!sections.length) return;

  // Create intersection observer
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          // Remove active from all links
          tocLinks.forEach((link) => link.classList.remove("active"));

          // Add active to matching link
          const activeLink = document.querySelector(
            `#toc a[href="#${entry.target.id}"]`
          );
          if (activeLink) {
            activeLink.classList.add("active");
          }
        }
      });
    },
    {
      threshold: 0,
      rootMargin: "-100px 0px -66% 0px",
    }
  );

  // Observe all sections
  sections.forEach((section) => observer.observe(section));

  // Set initial active state based on scroll position
  const setInitialActive = () => {
    const scrollPos = window.scrollY + 150;
    let currentSection = sections[0];

    sections.forEach((section) => {
      if (section.offsetTop <= scrollPos) {
        currentSection = section;
      }
    });

    tocLinks.forEach((link) => link.classList.remove("active"));
    const activeLink = document.querySelector(
      `#toc a[href="#${currentSection.id}"]`
    );
    if (activeLink) {
      activeLink.classList.add("active");
    }
  };

  // Set initial state after a small delay
  setTimeout(setInitialActive, 100);
});
