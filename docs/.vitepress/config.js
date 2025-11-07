import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Les AL - Documentation',
  description: 'Documentation technique du systeme de reservation pour pub anglais',
  base: '/restau-reservation-flutter/',
  
  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'Les AL',
    
    nav: [
      { text: 'Accueil', link: '/' },
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Projet', link: '/guide/gestion-taches' },
      { text: 'API', link: '/api/endpoints' }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Guide de demarrage',
          items: [
            { text: 'Introduction', link: '/guide/getting-started' },
            { text: 'Gestion des taches', link: '/guide/gestion-taches' },
            { text: 'Gestion des roles', link: '/guide/roles' }
          ]
        }
      ],
      '/frontend/': [
        {
          text: 'Frontend Flutter',
          items: [
            { text: 'Architecture', link: '/frontend/architecture' },
            { text: 'Ecrans', link: '/frontend/screens' },
            { text: 'Services', link: '/frontend/services' },
            { text: 'Theme et design', link: '/frontend/theme' },
            { text: 'Navigation', link: '/frontend/navigation' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'Documentation API',
          items: [
            { text: 'Endpoints', link: '/api/endpoints' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/Nouhamk/restau-reservation-flutter' }
    ],

    footer: {
      message: 'Documentation du systeme de reservation Les AL',
      copyright: 'Copyright 2025 Les AL - Projet academique'
    },

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/Nouhamk/restau-reservation-flutter/edit/nouhamk/frontend/docs/:path',
      text: 'Modifier cette page sur GitHub'
    },

    lastUpdated: {
      text: 'Derniere mise a jour',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'short'
      }
    }
  },

  markdown: {
    lineNumbers: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    }
  }
})