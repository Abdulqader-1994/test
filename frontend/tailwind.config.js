/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    screens: {
      xs: { max: '499.9px' },
      sm: { min: '500px', max: '695.9px' },
      md: { min: '696px', max: '927.9px' },
      lg: { min: '928px', max: '1199.9px' },
      xl: { min: '1200px' },
    },
  },
  plugins: [],
}

