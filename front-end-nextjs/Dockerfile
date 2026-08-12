#----- stage: 1 install dependencies -------
FROM node:20-alpine AS deps 

WORKDIR /app 
COPY package*.json . 
RUN npm ci

# ---- stage: 2 build the app -----
FROM node:20-alpine AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . . 

# for the ingress configuration
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

RUN npm run build 

# --- stage: 3 run the production server ---
FROM node:20-alpine AS runner 

WORKDIR /app 
ENV NODE_ENV=production
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser 

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]