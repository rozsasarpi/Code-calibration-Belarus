rm(list=ls(all=TRUE))

# ====================================================================
# INITIALIZE
# ====================================================================

library(ggplot2)
library(ggthemes)
library(readr)
library(scales)
library(tibble)
library(magrittr)
library(dplyr)
library(reshape2)

# ====================================================================
# CONTROL & SETTINGS
# ====================================================================


# ====================================================================
# PRE-PROCESS
# ====================================================================

df        = read_delim('data/prevalency_weights.csv', delim = ';')

df$khi    = as.numeric(df$khi)
# df$khi    = as.factor(df$khi) # looks good only if it is evenly spaced
df$model  = as.factor(df$model)


df        = melt(df,
                 id.vars = c('khi', 'model'),
                 variable.name = 'action',
                 value.name = 'weight') %>%
            as.tibble()

# ====================================================================
# VISUALIZE
# ====================================================================

levels(df$action) = c('Snow', 'Imposed', 'Wind')
df$model = factor(df$model, levels = c('this paper 1', 'this paper 2', 'Bairan &  Casas', 'Beck & Sousa'))

# mark the subfigures which are not in the literature but filled by us
df$source = 1
# df %>% mutate(source = ifelse(model == 'Bairan &  Casas' & (action == 'Snow' | action == 'Wind'), 0, source))
idx = df$model == 'Bairan &  Casas' & (df$action == 'Snow' | df$action == 'Wind')
df[idx,'source'] = 0
df[idx,'weight'] = NA
idx = df$model == 'Beck & Sousa' & (df$action == 'Snow')
df[idx,'source'] = 0
df[idx,'weight'] = NA

df$source = factor(df$source)

# PLOT
g = ggplot(df, aes(x = khi, y = weight, fill = source))
g = g + geom_col(position = 'dodge')
g = g + geom_text(aes(label = weight, y = weight + 10),
                  size = 3, color = 'gray40')
g = g + facet_grid(model ~ action)

g = g + scale_x_continuous(breaks = unique(df$khi))
# g = g + scale_fill_discrete(guide = F)
g = g + scale_fill_brewer(palette="Set1", guide = F)

g = g + theme_bw()
g = g + theme(axis.text.x=element_text(angle = 90, hjust = 0))
g = g + ylim(c(0.0, 90))
g = g + ylab('Weight, w [%]')
g = g + xlab(expression('Load ratio,' ~ chi ~ '[-]'))

print(g)

# ====================================================================
# VISUALIZE
# ====================================================================

ggsave('figures/prevalency_weights_rem.png',
       dpi = 1200)

# ggsave('figures/prevalency_weights.png',
#        units = 'mm',
#        width = 250, height = 200,
#        dpi = 1200)

