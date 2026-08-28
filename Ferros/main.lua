--atlas

SMODS.Atlas {
    key = 'Jokerzz',
    path = 'Test.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'Carburiz',
    path = 'Test.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'BldGd',
    path = 'Test.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'StlBr',
    path = 'Test.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'nugget',
    path = 'Test.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'templus',
    path = 'Test.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'templusplus',
    path = 'Test.png',
    px = 71,
    py = 95
}

--joker

SMODS.Joker {
    key = 'STMNG',
    loc_txt = {
        name = 'Steel Man',
        text = {
            'All played {C:attention}face{} cards become',
            '{C:attention}Steel{} cards when scored'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Jokerzz',
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local converted = false
            for _, val in ipairs(context.scoring_hand) do
                if val:is_face() and val.ability.effect ~= 'Steel Card' then
                    val:set_ability(G.P_CENTERS.m_steel, nil, true)
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            val:juice_up()
                            return true
                        end
                    }))
                    converted = true
                end
            end

            if converted then
                return {
                    message = 'Steel!',
                    colour = G.C.ORANGE,
                    card = card
                }
            end
        end
    end
}
SMODS.Joker {
    key = 'Carbu',
    loc_txt = {
        name = 'Carburizer',
        text = {
            '{X:mult,C:white}X2{} Mult for each scoring',
            '{C:attention}Steel{} card played'
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Carburiz',
    pos = { x = 0, y = 0 },
    rarity = 3,
    cost = 6,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.ability.effect == 'Steel Card' then
                return {
                    x_mult = 2,
                    card = card
                }
            end
        end
    end
}
SMODS.Joker {
    key = 'steel_ball_run',
    loc_txt = {
        name = 'Steel Ball',
        text = {
            '{C:attention}+1{} Hand Size for every',
            '{C:attention}3{} Steel cards in your deck',
            '{C:inactive}(Currently {C:attention}+#1#{C:inactive} Hand Size)'
        }
    },
    atlas = 'StlBr',
    pos = { x = 0, y = 0 }, 
    rarity = 4,
    cost = 6,
    blueprint_compat = false,
    config = { extra = { bonus = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,
    update = function(self, card, dt)
        if G.playing_cards and G.hand and not card.debuff then
            local steel_count = 0
            for _, v in pairs(G.playing_cards) do
                if v.config.center_key == 'm_steel' then
                    steel_count = steel_count + 1
                end
            end

            local expected_bonus = math.floor(steel_count / 3)
            if expected_bonus ~= card.ability.extra.bonus then
                local diff = expected_bonus - card.ability.extra.bonus
                G.hand:change_size(diff)
                card.ability.extra.bonus = expected_bonus
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if G.hand and card.ability.extra.bonus ~= 0 then
            G.hand:change_size(-card.ability.extra.bonus)
            card.ability.extra.bonus = 0
        end
    end
}
SMODS.Joker {
    key = 'golden_steel',
    loc_txt = {
        name = 'Blue Gold',
        text = {
            '{C:attention}Steel{} cards held in hand',
            'at end of round give {C:money}$3{}'
        }
    },
    atlas = 'nugget', 
    pos = { x = 0, y = 0 }, 
    rarity = 2,
    cost = 644,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition then
            local total_dollars = 0
            for _, v in ipairs(G.hand.cards) do
                if v.config.center_key == 'm_steel' and not v.debuff then
                    total_dollars = total_dollars + 3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            v:juice_up()
                            return true
                        end
                    }))
                end
            end
            if total_dollars > 0 then
                return {
                    message = '+$' .. total_dollars,
                    dollars = total_dollars,
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
}

--consumables
SMODS.Consumable {
    set = 'Tarot',
    key = 'blood_god',
    loc_txt = {
        name = 'Blood for the Blood God',
        text = {
            'Permanently increases',
            '{C:attention}Steel Card{} bonus by',
            '{X:mult,C:white}+X0.1{} while held in hand'
        }
    },
    atlas = 'BldGd',
    pos = { x = 0, y = 0 },
    cost = 3,
    unlocked = true,
    discovered = true,

    can_use = function(self, card)
        return true
    end,
   use = function(self, card, area, copier)
        local current_mult = G.GAME.steel_mult or 1.5
        G.GAME.steel_mult = current_mult + 0.1
        G.P_CENTERS.m_steel.config.h_x_mult = G.GAME.steel_mult

        if G.playing_cards then
            for _, v in pairs(G.playing_cards) do
                if v.config.center_key == 'm_steel' then
                    v.ability.h_x_mult = G.GAME.steel_mult
                end
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)

                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = current_mult .. "X + 0.1X",
                    colour = G.C.RED
                })
                return true
            end
        }))
    end
}
local card_h_x_mult_ref = Card.get_chip_h_x_mult
function Card.get_chip_h_x_mult(self)
    if self.ability.effect == 'Steel Card' and self.config.center_key == 'm_steel' then
        return G.GAME.steel_mult or 1.5
    end
    return card_h_x_mult_ref(self)
end

--vouchers
SMODS.Voucher {
    key = 'temperance_plus',
    loc_txt = {
        name = 'Greed',
        text = {
            'Doubles the maximum payout',
            'of {C:tarot}Temperance{} cards',
            '{C:inactive}(Max {C:money}$100{C:inactive})'
        }
    },
    atlas = 'templus',
    pos = { x = 0, y = 0 },
    cost = 10,
    unlocked = false,
    discovered = true,
    unlock_condition = { extra = 50 },
    redeem = function(self)
        G.GAME.temperance_cap = 100
        G.P_CENTERS.c_temperance.config.extra = 100
    end,
    check_for_unlock = function(self, args)
        if args.type == 'temperance_payout' and args.payout >= 50 then
            return true
        end
    end
}
SMODS.Voucher {
    key = 'temperance_plus_plus',
    loc_txt = {
        name = 'Avarice',
        text = {
            'Doubles the maximum payout',
            'of {C:tarot}Temperance{} cards again',
            '{C:inactive}(Max {C:money}$200{C:inactive})'
        }
    },
    atlas = 'templusplus',
    pos = { x = 0, y = 0 },
    cost = 10,
    unlocked = false,   
    discovered = true,
    requires = { 'v_temperance_plus' }, 
    unlock_condition = { extra = 50 },
    redeem = function(self)
        G.GAME.temperance_cap = 200
        G.P_CENTERS.c_temperance.config.extra = 200
    end,
    check_for_unlock = function(self, args)
        if args.type == 'temperance_payout' and args.payout >= 50 then
            return true
        end
    end
}
G.P_CENTERS.c_temperance.use = function(self, card, area, copier)
    local max_payout = G.GAME.temperance_cap or 50
    local money = 0
    if G.jokers then
        for i = 1, #G.jokers.cards do
            money = money + G.jokers.cards[i].sell_cost
        end
    end
    if money >= 50 then
        check_for_unlock({type = 'temperance_payout', payout = money})
    end

    money = math.min(money, max_payout)
    ease_dollars(math.max(1, money))
end
local ui_table_ref = Card.generate_UIBox_ability_table
function Card.generate_UIBox_ability_table(self)
    if self.config and self.config.center and self.config.center.key == 'c_temperance' then
        self.ability.extra = G.GAME.temperance_cap or 50
    end
    return ui_table_ref(self)
end