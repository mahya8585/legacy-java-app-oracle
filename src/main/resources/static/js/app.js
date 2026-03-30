// Navigation toggle for mobile
function toggleNav() {
    var menu = document.getElementById('navMenu');
    if (menu) {
        menu.classList.toggle('active');
    }
}

// Confirm dialog for destructive actions
function confirmAction(message) {
    return confirm(message || '本当に実行しますか？');
}

// Format currency
function formatCurrency(amount) {
    return '¥' + Number(amount).toLocaleString();
}

// Auto-dismiss alerts after 5 seconds
document.addEventListener('DOMContentLoaded', function() {
    var alerts = document.querySelectorAll('.alert[data-auto-dismiss]');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(function() {
                alert.remove();
            }, 500);
        }, 5000);
    });
});
