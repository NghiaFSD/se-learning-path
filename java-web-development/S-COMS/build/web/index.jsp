<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Diabetes Monitoring & Early Warning System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
    <style>
        :root {
            --primary-color: #2dbbbc;
            --primary-dark: #239495;
            --primary-light: #e8f7f4;
            --gradient-start: #f4fbf9;
            --gradient-end: #e8f7f4;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            overflow-x: hidden;
        }

        /* Modern Navbar */
        .modern-navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.05);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
        }

        .modern-navbar.scrolled {
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.08);
        }

        .nav-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.5rem;
            color: var(--primary-color);
        }

        .brand-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2rem;
        }

        .nav-link {
            text-decoration: none;
            color: #64748b;
            font-weight: 500;
            transition: color 0.3s ease;
            position: relative;
        }

        .nav-link:hover {
            color: var(--primary-color);
        }

        .nav-link::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            width: 0;
            height: 2px;
            background: var(--primary-color);
            transition: width 0.3s ease;
        }

        .nav-link:hover::after {
            width: 100%;
        }

        .btn-primary-nav {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border: none;
        }

        .btn-primary-nav:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(45, 187, 188, 0.35);
            color: white;
        }

        /* Language Switcher */
        .lang-switcher {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.75rem;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            color: #64748b;
            transition: all 0.2s ease;
        }

        .lang-switcher:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
        }

        .lang-dropdown {
            position: absolute;
            top: 100%;
            right: 0;
            margin-top: 0.5rem;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            min-width: 140px;
            z-index: 1001;
            display: none;
        }

        .lang-dropdown.active {
            display: block;
        }

        .lang-option {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1rem;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 0.875rem;
        }

        .lang-option:hover {
            background: #f8fafc;
        }

        .lang-option.active {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
            font-weight: 600;
        }

        .lang-flag {
            font-size: 1.125rem;
        }

        /* Hero Section */
        .hero-modern {
            min-height: 100vh;
            background: linear-gradient(135deg, var(--gradient-start) 0%, var(--gradient-end) 100%);
            display: flex;
            align-items: center;
            padding-top: 100px;
            position: relative;
            overflow: hidden;
        }

        .hero-modern::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 800px;
            height: 800px;
            background: radial-gradient(circle, rgba(45, 187, 188, 0.08) 0%, transparent 70%);
            border-radius: 50%;
        }

        .hero-modern::after {
            content: '';
            position: absolute;
            bottom: -30%;
            left: -10%;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(45, 187, 188, 0.05) 0%, transparent 70%);
            border-radius: 50%;
        }

        .hero-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 4rem 2rem;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
        }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            line-height: 1.1;
            color: #1e293b;
            margin-bottom: 1.5rem;
        }

        .hero-title span {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-description {
            font-size: 1.125rem;
            color: #64748b;
            line-height: 1.7;
            margin-bottom: 2rem;
            max-width: 500px;
        }

        .hero-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .btn-hero-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            padding: 1rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            border: none;
        }

        .btn-hero-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(45, 187, 188, 0.4);
            color: white;
        }

        .btn-hero-secondary {
            background: white;
            color: #1e293b;
            padding: 1rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            border: 2px solid #e2e8f0;
        }

        .btn-hero-secondary:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
            transform: translateY(-3px);
        }

        /* Hero Image/Card */
        .hero-visual {
            position: relative;
        }

        .hero-card-modern {
            background: white;
            border-radius: 24px;
            padding: 2rem;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.1);
            position: relative;
        }

        .floating-card {
            position: absolute;
            background: white;
            border-radius: 16px;
            padding: 1.25rem;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
        }

        .floating-card-1 {
            top: -20px;
            right: -30px;
            animation: float 3s ease-in-out infinite;
        }

        .floating-card-2 {
            bottom: 20px;
            left: -40px;
            animation: float 3s ease-in-out infinite 0.5s;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 800;
            color: var(--primary-color);
        }

        .stat-label {
            font-size: 0.875rem;
            color: #64748b;
        }

        /* Features Section */
        .features-section {
            padding: 6rem 2rem;
            background: white;
        }

        .section-header {
            text-align: center;
            max-width: 600px;
            margin: 0 auto 4rem;
        }

        .section-tag {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 1rem;
        }

        .section-subtitle {
            color: #64748b;
            font-size: 1.125rem;
        }

        .features-grid {
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
        }

        .feature-card-modern {
            background: white;
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid #f1f5f9;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .feature-card-modern::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-color), var(--primary-dark));
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .feature-card-modern:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
            border-color: transparent;
        }

        .feature-card-modern:hover::before {
            transform: scaleX(1);
        }

        .feature-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, rgba(45, 187, 188, 0.1), rgba(45, 187, 188, 0.2));
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .feature-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.75rem;
        }

        .feature-desc {
            color: #64748b;
            line-height: 1.6;
        }

        /* AI Section */
        .ai-section {
            padding: 6rem 2rem;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }

        .ai-container {
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
        }

        .ai-content {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 24px;
            padding: 3rem;
            color: white;
            position: relative;
            overflow: hidden;
        }

        .ai-content::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
        }

        .ai-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1rem;
            position: relative;
        }

        .ai-desc {
            opacity: 0.9;
            line-height: 1.7;
            margin-bottom: 2rem;
            position: relative;
        }

        .ai-list {
            list-style: none;
            position: relative;
        }

        .ai-list li {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1rem;
        }

        .ai-list li i {
            width: 24px;
            height: 24px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
        }

        .ai-cards {
            display: grid;
            gap: 1.5rem;
        }

        .ai-card-item {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }

        .ai-card-item:hover {
            transform: translateX(8px);
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
        }

        .ai-card-icon {
            width: 48px;
            height: 48px;
            background: rgba(45, 187, 188, 0.1);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 1.25rem;
            margin-bottom: 1rem;
        }

        .ai-card-title {
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.5rem;
        }

        .ai-card-desc {
            color: #64748b;
            font-size: 0.875rem;
        }

        /* Stats Section */
        .stats-section {
            padding: 4rem 2rem;
            background: white;
        }

        .stats-container {
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
        }

        .stat-card-modern {
            text-align: center;
            padding: 2rem;
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border-radius: 20px;
            transition: all 0.3s ease;
        }

        .stat-card-modern:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.08);
        }

        .stat-card-number {
            font-size: 3rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
        }

        .stat-card-label {
            color: #64748b;
            font-weight: 500;
        }

        /* CTA Section */
        .cta-section {
            padding: 6rem 2rem;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            text-align: center;
            color: white;
        }

        .cta-container {
            max-width: 800px;
            margin: 0 auto;
        }

        .cta-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .cta-desc {
            font-size: 1.125rem;
            opacity: 0.9;
            margin-bottom: 2rem;
        }

        .btn-cta {
            background: white;
            color: var(--primary-color);
            padding: 1rem 2.5rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.125rem;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .btn-cta:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            color: var(--primary-color);
        }

        /* Footer */
        .footer-modern {
            background: #0f172a;
            color: white;
            padding: 4rem 2rem 2rem;
        }

        .footer-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 3rem;
            margin-bottom: 3rem;
        }

        .footer-brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1rem;
        }

        .footer-brand-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .footer-brand-text {
            font-weight: 700;
            font-size: 1.25rem;
        }

        .footer-desc {
            color: #94a3b8;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        .footer-title {
            font-weight: 600;
            margin-bottom: 1rem;
            color: white;
        }

        .footer-links {
            list-style: none;
        }

        .footer-links li {
            margin-bottom: 0.75rem;
        }

        .footer-links a {
            color: #94a3b8;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-links a:hover {
            color: var(--primary-color);
        }

        .footer-bottom {
            border-top: 1px solid #1e293b;
            padding-top: 2rem;
            text-align: center;
            color: #64748b;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .hero-content {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .hero-description {
                margin-left: auto;
                margin-right: auto;
            }

            .features-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .ai-container {
                grid-template-columns: 1fr;
            }

            .stats-container {
                grid-template-columns: repeat(2, 1fr);
            }

            .footer-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }

            .nav-links {
                display: none;
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .stats-container {
                grid-template-columns: 1fr;
            }

            .footer-grid {
                grid-template-columns: 1fr;
                gap: 2rem;
            }

            .floating-card {
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="modern-navbar" id="navbar">
        <div class="nav-container">
            <a href="index.jsp" class="brand">
                <div class="brand-icon">
                    <i class="bi bi-heart-pulse-fill"></i>
                </div>
                <span>DiabetesCare</span>
            </a>
            <div class="nav-links">
                <a href="index.jsp" class="nav-link" data-i18n="home">Home</a>
                <a href="login.jsp" class="nav-link" data-i18n="login">Login</a>
                <a href="register.jsp" class="nav-link" data-i18n="register">Register</a>
                <div style="position: relative;">
                    <button class="lang-switcher" onclick="toggleLangDropdown()">
                        <i class="bi bi-globe"></i>
                        <span id="currentLang">English</span>
                        <i class="bi bi-chevron-down" style="font-size: 0.75rem;"></i>
                    </button>
                    <div class="lang-dropdown" id="langDropdown">
                        <div class="lang-option active" onclick="switchLanguage('en')">
                            <span class="lang-flag">🇺🇸</span>
                            <span>English</span>
                        </div>
                        <div class="lang-option" onclick="switchLanguage('vi')">
                            <span class="lang-flag">🇻🇳</span>
                            <span>Tiếng Việt</span>
                        </div>
                    </div>
                </div>
                <a href="login.jsp" class="btn-primary-nav" data-i18n="startAiChat">Start AI Chat</a>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-modern">
        <div class="hero-content">
            <div class="hero-text">
                <div class="hero-badge">
                    <i class="bi bi-shield-check"></i>
                    <span data-i18n="healthcareSystem">Healthcare Intelligence System</span>
                </div>
                <h1 class="hero-title" data-i18n="heroTitle">
                    Diabetes <span>Monitoring</span> & Early Warning System
                </h1>
                <p class="hero-description" data-i18n="heroDescription">
                    Monitor medical records, support early diabetes detection, and empower patients with AI-assisted care while doctors make final decisions.
                </p>
                <div class="hero-buttons">
                    <a href="register.jsp" class="btn-hero-primary">
                        <span data-i18n="getStarted">Get Started Now</span>
                        <i class="bi bi-arrow-right"></i>
                    </a>
                    <a href="login.jsp" class="btn-hero-secondary">
                        <i class="bi bi-play-circle"></i>
                        <span data-i18n="watchDemo">Watch Demo</span>
                    </a>
                </div>
            </div>
            <div class="hero-visual">
                <div class="hero-card-modern">
                    <h5 class="fw-bold mb-3 text-dark">
                        <i class="bi bi-activity text-vinmec me-2"></i>Real-time Health Monitoring
                    </h5>
                    <p class="text-secondary small mb-4">Track your vital signs with precision and get instant insights.</p>
                    <div class="d-flex justify-content-between mb-4">
                        <div>
                            <div class="stat-number">98%</div>
                            <div class="stat-label">Accuracy</div>
                        </div>
                        <div>
                            <div class="stat-number">24/7</div>
                            <div class="stat-label">Monitoring</div>
                        </div>
                        <div>
                            <div class="stat-number">15k+</div>
                            <div class="stat-label">Patients</div>
                        </div>
                    </div>
                    <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar" role="progressbar" style="width: 75%; background: linear-gradient(90deg, #2dbbbc, #239495);"></div>
                    </div>
                    <small class="text-muted">Glucose Level: 7.8 mmol/L (Normal)</small>
                </div>
                <div class="floating-card floating-card-1">
                    <div class="d-flex align-items-center gap-3">
                        <div class="bg-success rounded-circle p-2">
                            <i class="bi bi-check-lg text-white"></i>
                        </div>
                        <div>
                            <div class="fw-bold text-dark">Health Check</div>
                            <small class="text-muted">All systems normal</small>
                        </div>
                    </div>
                </div>
                <div class="floating-card floating-card-2">
                    <div class="d-flex align-items-center gap-2 text-warning">
                        <i class="bi bi-bell-fill"></i>
                        <span class="fw-semibold">3 Alerts</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section">
        <div class="stats-container">
            <div class="stat-card-modern">
                <div class="stat-card-number">15k+</div>
                <div class="stat-card-label">Active Patients</div>
            </div>
            <div class="stat-card-modern">
                <div class="stat-card-number">98%</div>
                <div class="stat-card-label">Patient Satisfaction</div>
            </div>
            <div class="stat-card-modern">
                <div class="stat-card-number">24/7</div>
                <div class="stat-card-label">AI Monitoring</div>
            </div>
            <div class="stat-card-modern">
                <div class="stat-card-number">50+</div>
                <div class="stat-card-label">Expert Doctors</div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section">
        <div class="section-header">
            <div class="section-tag">
                <i class="bi bi-stars"></i>
                <span data-i18n="ourFeatures">Our Features</span>
            </div>
            <h2 class="section-title" data-i18n="completeSolution">Complete Healthcare Solution</h2>
            <p class="section-subtitle" data-i18n="featuresSubtitle">From patient onboarding to AI-assisted risk scoring, our system is built for safety, clarity, and clinical support.</p>
        </div>
        <div class="features-grid">
            <div class="feature-card-modern">
                <div class="feature-icon">
                    <i class="bi bi-file-medical"></i>
                </div>
                <h3 class="feature-title" data-i18n="patientRegistration">Patient Registration</h3>
                <p class="feature-desc" data-i18n="patientRegistrationDesc">Secure and simple registration process for patients to create their health profiles.</p>
            </div>
            <div class="feature-card-modern">
                <div class="feature-icon">
                    <i class="bi bi-exclamation-triangle"></i>
                </div>
                <h3 class="feature-title" data-i18n="riskAssessment">Risk Assessment</h3>
                <p class="feature-desc" data-i18n="riskAssessmentDesc">AI-powered early warning system for diabetes risk detection and monitoring.</p>
            </div>
            <div class="feature-card-modern">
                <div class="feature-icon">
                    <i class="bi bi-robot"></i>
                </div>
                <h3 class="feature-title" data-i18n="aiChatAssistant">AI Chat Assistant</h3>
                <p class="feature-desc" data-i18n="aiChatAssistantDesc">Intelligent chatbot helps patients track symptoms and provides health guidance.</p>
            </div>
        </div>
    </section>

    <!-- AI Section -->
    <section class="ai-section">
        <div class="ai-container">
            <div class="ai-content">
                <h3 class="ai-title" data-i18n="aiAssessment">
                    <i class="bi bi-cpu me-2"></i>AI Risk Assessment
                </h3>
                <p class="ai-desc" data-i18n="aiAssessmentDesc">
                    Our AI assistant gathers health signals like glucose, BMI, blood pressure, and family history to flag early signs of diabetes risk.
                </p>
                <ul class="ai-list">
                    <li data-i18n="aiFeature1">
                        <i class="bi bi-check"></i>
                        Structured health capture from conversation
                    </li>
                    <li data-i18n="aiFeature2">
                        <i class="bi bi-check"></i>
                        Model-based risk suggestions, not diagnosis
                    </li>
                    <li data-i18n="aiFeature3">
                        <i class="bi bi-check"></i>
                        Doctor-facing recommendations and alerts
                    </li>
                    <li data-i18n="aiFeature4">
                        <i class="bi bi-check"></i>
                        Continuous learning from patient data
                    </li>
                </ul>
            </div>
            <div class="ai-cards">
                <div class="ai-card-item">
                    <div class="ai-card-icon">
                        <i class="bi bi-heart-pulse"></i>
                    </div>
                    <h4 class="ai-card-title">Risk Assessment</h4>
                    <p class="ai-card-desc">Advanced algorithms analyze multiple health factors to provide comprehensive risk profiles.</p>
                </div>
                <div class="ai-card-item">
                    <div class="ai-card-icon">
                        <i class="bi bi-graph-up-arrow"></i>
                    </div>
                    <h4 class="ai-card-title">Trend Analysis</h4>
                    <p class="ai-card-desc">Track health metrics over time with visual charts and predictive insights.</p>
                </div>
                <div class="ai-card-item">
                    <div class="ai-card-icon">
                        <i class="bi bi-bell"></i>
                    </div>
                    <h4 class="ai-card-title">Smart Alerts</h4>
                    <p class="ai-card-desc">Timely notifications for both patients and doctors when attention is needed.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <div class="cta-container">
            <h2 class="cta-title">Ready to Take Control of Your Health?</h2>
            <p class="cta-desc">Join thousands of patients who trust our system for their diabetes monitoring and early warning needs.</p>
            <a href="register.jsp" class="btn-cta">
                Create Free Account
                <i class="bi bi-arrow-right ms-2"></i>
            </a>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer-modern">
        <div class="footer-container">
            <div class="footer-grid">
                <div>
                    <div class="footer-brand">
                        <div class="footer-brand-icon">
                            <i class="bi bi-heart-pulse-fill"></i>
                        </div>
                        <span class="footer-brand-text">DiabetesCare</span>
                    </div>
                    <p class="footer-desc" data-i18n="footerDesc">
                        An advanced clinical dashboard design for diabetes care with AI-assisted patient interaction and real-time medical record tracking.
                    </p>
                </div>
                <div>
                    <h4 class="footer-title" data-i18n="product">Product</h4>
                    <ul class="footer-links">
                        <li><a href="#" data-i18n="features">Features</a></li>
                        <li><a href="#" data-i18n="pricing">Pricing</a></li>
                        <li><a href="#" data-i18n="documentation">Documentation</a></li>
                        <li><a href="#" data-i18n="api">API</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-title" data-i18n="company">Company</h4>
                    <ul class="footer-links">
                        <li><a href="#" data-i18n="aboutUs">About Us</a></li>
                        <li><a href="#" data-i18n="careers">Careers</a></li>
                        <li><a href="#" data-i18n="blog">Blog</a></li>
                        <li><a href="#" data-i18n="contact">Contact</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-title" data-i18n="support">Support</h4>
                    <ul class="footer-links">
                        <li><a href="#" data-i18n="helpCenter">Help Center</a></li>
                        <li><a href="#" data-i18n="privacyPolicy">Privacy Policy</a></li>
                        <li><a href="#" data-i18n="termsOfService">Terms of Service</a></li>
                        <li><a href="#">support@diabetes-monitoring.edu</a></li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p data-i18n="copyright">© 2026 Diabetes Monitoring & Early Warning System. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.getElementById('navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Smooth scroll
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });

        // ==========================================
        // LANGUAGE TRANSLATION SYSTEM
        // ==========================================

        const translations = {
            en: {
                // Navbar
                home: 'Home',
                login: 'Login',
                register: 'Register',
                startAiChat: 'Start AI Chat',

                // Hero
                healthcareSystem: 'Healthcare Intelligence System',
                heroTitle: 'Diabetes Monitoring & Early Warning System',
                heroDescription: 'Monitor medical records, support early diabetes detection, and empower patients with AI-assisted care while doctors make final decisions.',
                getStarted: 'Get Started Now',
                watchDemo: 'Watch Demo',

                // Features Section
                ourFeatures: 'Our Features',
                completeSolution: 'Complete Healthcare Solution',
                featuresSubtitle: 'From patient onboarding to AI-assisted risk scoring, our system is built for safety, clarity, and clinical support.',

                // Feature Cards
                patientRegistration: 'Patient Registration',
                patientRegistrationDesc: 'Secure and simple registration process for patients to create their health profiles.',
                aiChatAssistant: 'AI Chat Assistant',
                aiChatAssistantDesc: 'Intelligent chatbot helps patients track symptoms and provides health guidance.',
                medicalRecords: 'Medical Records',
                medicalRecordsDesc: 'Comprehensive digital records with easy access to health history and reports.',
                riskAssessment: 'Risk Assessment',
                riskAssessmentDesc: 'AI-powered early warning system for diabetes risk detection and monitoring.',
                doctorDashboard: 'Doctor Dashboard',
                doctorDashboardDesc: 'Professional interface for healthcare providers to manage patient care.',
                realTimeMonitoring: 'Real-time Monitoring',
                realTimeMonitoringDesc: 'Continuous health tracking with instant alerts and notifications.',

                // AI Section
                aiAssessment: 'AI Risk Assessment',
                aiAssessmentDesc: 'Our AI assistant gathers health signals like glucose, BMI, blood pressure, and family history to flag early signs of diabetes risk.',
                aiFeature1: 'Structured health capture from conversation',
                aiFeature2: 'Model-based risk suggestions, not diagnosis',
                aiFeature3: 'Doctor-facing recommendations and alerts',
                aiFeature4: 'Continuous learning from patient data',

                // Footer
                footerDesc: 'An advanced clinical dashboard design for diabetes care with AI-assisted patient interaction and real-time medical record tracking.',
                product: 'Product',
                company: 'Company',
                support: 'Support',
                features: 'Features',
                pricing: 'Pricing',
                documentation: 'Documentation',
                api: 'API',
                aboutUs: 'About Us',
                careers: 'Careers',
                blog: 'Blog',
                contact: 'Contact',
                helpCenter: 'Help Center',
                privacyPolicy: 'Privacy Policy',
                termsOfService: 'Terms of Service',
                copyright: '© 2026 Diabetes Monitoring & Early Warning System. All rights reserved.'
            },
            vi: {
                // Navbar
                home: 'Trang chủ',
                login: 'Đăng nhập',
                register: 'Đăng ký',
                startAiChat: 'Bắt đầu Chat AI',

                // Hero
                healthcareSystem: 'Hệ thống Y tế Thông minh',
                heroTitle: 'Giám sát Tiểu đường & Cảnh báo Sớm',
                heroDescription: 'Theo dõi hồ sơ y tế, hỗ trợ phát hiện tiểu đường sớm, và hỗ trợ bệnh nhân với chăm sóc AI trong khi bác sĩ đưa ra quyết định cuối cùng.',
                getStarted: 'Bắt đầu ngay',
                watchDemo: 'Xem Demo',

                // Features Section
                ourFeatures: 'Tính năng của chúng tôi',
                completeSolution: 'Giải pháp Chăm sóc Sức khỏe Toàn diện',
                featuresSubtitle: 'Từ đăng ký bệnh nhân đến đánh giá rủi ro hỗ trợ AI, hệ thống của chúng tôi được xây dựng cho sự an toàn, rõ ràng và hỗ trợ lâm sàng.',

                // Feature Cards
                patientRegistration: 'Đăng ký Bệnh nhân',
                patientRegistrationDesc: 'Quy trình đăng ký an toàn và đơn giản để bệnh nhân tạo hồ sơ sức khỏe.',
                aiChatAssistant: 'Trợ lý Chat AI',
                aiChatAssistantDesc: 'Chatbot thông minh giúp bệnh nhân theo dõi triệu chứng và cung cấp hướng dẫn sức khỏe.',
                medicalRecords: 'Hồ sơ Y tế',
                medicalRecordsDesc: 'Hồ sơ số toàn diện với truy cập dễ dàng vào lịch sử sức khỏe và báo cáo.',
                riskAssessment: 'Đánh giá Rủi ro',
                riskAssessmentDesc: 'Hệ thống cảnh báo sớm dựa trên AI để phát hiện và theo dõi nguy cơ tiểu đường.',
                doctorDashboard: 'Bảng điều khiển Bác sĩ',
                doctorDashboardDesc: 'Giao diện chuyên nghiệp cho nhà cung cấp dịch vụ y tế để quản lý chăm sóc bệnh nhân.',
                realTimeMonitoring: 'Giám sát Thời gian thực',
                realTimeMonitoringDesc: 'Theo dõi sức khỏe liên tục với cảnh báo và thông báo tức thì.',

                // AI Section
                aiAssessment: 'Đánh giá Rủi ro AI',
                aiAssessmentDesc: 'Trợ lý AI của chúng tôi thu thập các tín hiệu sức khỏe như đường huyết, BMI, huyết áp và tiền sử gia đình để phát hiện dấu hiệu tiểu đường sớm.',
                aiFeature1: 'Thu thập sức khỏe có cấu trúc từ cuộc trò chuyện',
                aiFeature2: 'Gợi ý rủi ro dựa trên mô hình, không phải chẩn đoán',
                aiFeature3: 'Khuyến nghị và cảnh báo hướng đến bác sĩ',
                aiFeature4: 'Học liên tục từ dữ liệu bệnh nhân',

                // Footer
                footerDesc: 'Thiết kế bảng điều khiển lâm sàng nâng cao cho chăm sóc tiểu đường với tương tác bệnh nhân hỗ trợ AI và theo dõi hồ sơ y tế thời gian thực.',
                product: 'Sản phẩm',
                company: 'Công ty',
                support: 'Hỗ trợ',
                features: 'Tính năng',
                pricing: 'Giá cả',
                documentation: 'Tài liệu',
                api: 'API',
                aboutUs: 'Về chúng tôi',
                careers: 'Tuyển dụng',
                blog: 'Blog',
                contact: 'Liên hệ',
                helpCenter: 'Trung tâm Trợ giúp',
                privacyPolicy: 'Chính sách Bảo mật',
                termsOfService: 'Điều khoản Dịch vụ',
                copyright: '© 2026 Hệ thống Giám sát Tiểu đường & Cảnh báo Sớm. Đã đăng ký bản quyền.'
            }
        };

        let currentLanguage = localStorage.getItem('diabetesAppLang') || 'en';

        // Toggle language dropdown
        function toggleLangDropdown() {
            const dropdown = document.getElementById('langDropdown');
            dropdown.classList.toggle('active');
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            const dropdown = document.getElementById('langDropdown');
            const switcher = e.target.closest('.lang-switcher');
            if (!switcher && dropdown) {
                dropdown.classList.remove('active');
            }
        });

        // Switch language
        function switchLanguage(lang) {
            currentLanguage = lang;
            localStorage.setItem('diabetesAppLang', lang);

            // Update active state in dropdown
            document.querySelectorAll('.lang-option').forEach(opt => {
                opt.classList.remove('active');
            });
            event.target.closest('.lang-option').classList.add('active');

            // Update current language display
            const langNames = { en: 'English', vi: 'Tiếng Việt' };
            document.getElementById('currentLang').textContent = langNames[lang];

            // Apply translations
            applyTranslations();

            // Close dropdown
            document.getElementById('langDropdown').classList.remove('active');
        }

        // Apply translations
        function applyTranslations() {
            const t = translations[currentLanguage];

            // Update all elements with data-i18n attribute
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (t[key]) {
                    // Handle different element types
                    if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
                        el.placeholder = t[key];
                    } else {
                        // For elements with icons, preserve the icon
                        const icon = el.querySelector('i');
                        const span = el.querySelector('span');
                        
                        if (key === 'heroTitle' && span) {
                            // Special handling for hero title with styled span
                            span.textContent = 'Giám sát';
                            const textNodes = Array.from(el.childNodes).filter(n => n.nodeType === Node.TEXT_NODE);
                            textNodes.forEach(node => {
                                if (node.textContent.includes('Diabetes')) {
                                    node.textContent = 'Tiểu đường ';
                                } else if (node.textContent.includes('& Early Warning System')) {
                                    node.textContent = ' & Cảnh báo Sớm';
                                }
                            });
                        } else if (icon && !span) {
                            // Element with icon only
                            el.innerHTML = '';
                            el.appendChild(icon);
                            el.appendChild(document.createTextNode(' ' + t[key]));
                        } else {
                            // Simple element
                            el.textContent = t[key];
                        }
                    }
                }
            });
        }

        // Initialize language on page load
        document.addEventListener('DOMContentLoaded', function() {
            const savedLang = localStorage.getItem('diabetesAppLang');
            if (savedLang === 'vi') {
                document.getElementById('currentLang').textContent = 'Tiếng Việt';
                document.querySelectorAll('.lang-option').forEach(opt => {
                    opt.classList.remove('active');
                    if (opt.textContent.includes('Tiếng Việt')) {
                        opt.classList.add('active');
                    }
                });
                applyTranslations();
            }
        });
    </script>
</body>
</html>