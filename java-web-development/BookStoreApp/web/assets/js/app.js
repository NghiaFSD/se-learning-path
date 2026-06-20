/**
 * BookStoreApp - Main JavaScript
 * Global utilities and helper functions
 */

// Document Ready
document.addEventListener('DOMContentLoaded', function() {
    console.log('BookStoreApp initialized');
    
    // Initialize tooltips and popovers
    initializeBootstrapComponents();
    
    // Set active nav item
    setActiveNavigation();
});

/**
 * Initialize Bootstrap components (Tooltips, Popovers)
 */
function initializeBootstrapComponents() {
    // Tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Popovers
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
}

/**
 * Highlight active navigation item based on current page
 */
function setActiveNavigation() {
    const currentPage = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === currentPage || 
            currentPage.includes(link.getAttribute('href'))) {
            link.classList.add('active');
        }
    });
}

/**
 * Show toast notification
 * @param {string} message - Toast message
 * @param {string} type - 'success', 'error', 'warning', 'info'
 * @param {number} duration - Duration in milliseconds
 */
function showToast(message, type = 'info', duration = 3000) {
    const toastHTML = `
        <div class="toast align-items-center text-white bg-${getBootstrapColorClass(type)} border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body">
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    `;
    
    const toastContainer = document.getElementById('toastContainer') || createToastContainer();
    toastContainer.insertAdjacentHTML('beforeend', toastHTML);
    
    const toast = new bootstrap.Toast(toastContainer.lastChild);
    toast.show();
    
    setTimeout(() => toastContainer.lastChild.remove(), duration);
}

/**
 * Helper function to get Bootstrap color class
 */
function getBootstrapColorClass(type) {
    const colors = {
        'success': 'success',
        'error': 'danger',
        'warning': 'warning',
        'info': 'info'
    };
    return colors[type] || 'info';
}

/**
 * Create toast container if it doesn't exist
 */
function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'toast-container position-fixed bottom-0 end-0 p-3';
    document.body.appendChild(container);
    return container;
}

/**
 * Format currency (Vietnamese Dong)
 * @param {number} amount - Amount to format
 * @returns {string} Formatted currency string
 */
function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

/**
 * Format date to Vietnamese format
 * @param {Date|string} date - Date to format
 * @returns {string} Formatted date
 */
function formatDate(date) {
    const d = new Date(date);
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return d.toLocaleDateString('vi-VN', options);
}

/**
 * Debounce function for search input
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in milliseconds
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Confirm action with modal
 * @param {string} message - Confirmation message
 * @param {Function} callback - Callback if confirmed
 */
function confirmAction(message, callback) {
    if (confirm(message)) {
        callback();
    }
}

/**
 * Disable button temporarily (prevent double submit)
 * @param {HTMLElement} button - Button element
 * @param {number} duration - Duration in milliseconds
 */
function disableButtonTemporarily(button, duration = 2000) {
    button.disabled = true;
    button.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing...';
    
    setTimeout(() => {
        button.disabled = false;
        button.innerHTML = 'Submit';
    }, duration);
}

/**
 * Check if user is logged in by checking session
 */
function isLoggedIn() {
    return document.body.dataset.loggedIn === 'true';
}

/**
 * Redirect to login if not authenticated
 */
function requireLogin() {
    if (!isLoggedIn()) {
        window.location.href = 'login';
    }
}

/**
 * Export functions for use in other scripts
 */
window.BookStoreApp = {
    showToast,
    formatCurrency,
    formatDate,
    debounce,
    confirmAction,
    disableButtonTemporarily,
    isLoggedIn,
    requireLogin
};
