library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity adapt_4a8 is
    generic(
    N : natural := 8;
    M : natural := 2);
    port (
        rst_i     : in  std_logic;
        clk_i     : in  std_logic;

        s_data_i  : in  std_logic_vector(4-1 downto 0);
        
        

        m_data_o  : out std_logic_vector (8-1 downto 0);
        
        s_valid_i : in  std_logic;      -- Emisor : ANTERIOR | Motivo : Quiere escribir
        s_ready_o : out std_logic;      -- Destino : ANTERIOR | Motivo : Puedo leer
        m_valid_o : out std_logic;      -- Destino : SIGUIENTE | Motivo : Quiero escribir
        m_ready_i : in  std_logic       -- Emisor : SIGUIENTE | Motivo : Puede leer
        
    );
end adapt_4a8;

architecture arq_adapt_4a8 of adapt_4a8 is

	signal Q: std_logic_vector(8-1 downto 0);
    
    signal cnt_r   : natural := 0;
    
    constant SGTE_ESPERAR : std_logic := '0';
    constant SGTE_PROCESAR : std_logic := '1';
    
    constant ANT_ESPERAR : std_logic := '0';
    constant ANT_PROCESAR : std_logic := '1';
    
    constant SGTE_LISTO : std_logic := '1';
    constant YO_LISTO : std_logic := '1';

    signal state : std_logic := SGTE_PROCESAR;
begin
    process(clk_i, rst_i)
    
    begin
        if rst_i = '0' then
            Q <= (others => '0');
            m_valid_o <= SGTE_ESPERAR;                                   -- SGTE > No quiero escribir
            
          	s_ready_o <= ANT_PROCESAR;                                   -- ANTE > Puedo leer
            state <= ANT_PROCESAR;
        elsif (clk_i = '1' and clk_i'Event) then
        	if s_valid_i = YO_LISTO then        					     -- Puedo leer el dato que llega    
     
                case cnt_r is
                    when 2 =>
                    	m_valid_o <= SGTE_ESPERAR;                      -- SGTE > No quiero escribir
                        state <= SGTE_ESPERAR;
                        
                    	Q(0) <= s_data_i(0);
                        Q(1) <= s_data_i(1);
                        Q(2) <= s_data_i(2);
                        Q(3) <= s_data_i(3);
 
                        --s_ready_o <= ANT_ESPERAR;                        -- ANTE > No puedo leer
                        
                        --m_valid_o <= SGTE_PROCESAR;                     -- SGTE > Quiero escribir          
                    when 1 =>
                    	Q(4) <= s_data_i(0);
                        Q(5) <= s_data_i(1);
                        Q(6) <= s_data_i(2);
                        Q(7) <= s_data_i(3);
                        m_valid_o <= SGTE_PROCESAR;                      -- SGTE > Quiero escribir
                        state <= SGTE_PROCESAR;
                    when 0 =>
                    	--if (m_ready_i = '1') then
                        	
                            m_valid_o <= SGTE_PROCESAR;                      -- SGTE > Quiero escribir
                        	
                            
                            m_data_o <= Q;
                            
                    		s_ready_o <= ANT_PROCESAR;                      -- ANTE > Puedo leer  
                            state <= ANT_PROCESAR;
                        --end if;
                    when others => report "unreachable" severity failure;
                end case;
              	                     	
                  
            end if; 	           
        end if;	
    end process;
    
    process(clk_i, rst_i)
    begin
        if rst_i = '0' then
            cnt_r <= 2;
        elsif (clk_i = '1' and clk_i'Event) then
        	if state = SGTE_ESPERAR then        					-- SGTE > No quiero escribir              
                cnt_r <= cnt_r - 1;                         	
            else
            	cnt_r <= 2;
                --m_data_o <= Q;
                
            end if; 	           
        end if;	
    end process;

    --m_data_o <= Q; 
end arq_adapt_4a8;

