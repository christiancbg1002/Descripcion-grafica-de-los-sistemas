% Cargar los datos del archivo CSV como tabla
data = readtable('data_motor.csv'); 

% Extracción de las columnas (usando nombres de variables o índices)
t = data{:,2};  % Segunda columna (tiempo en segundos)
u = data{:,3};  % Tercera columna (ex_signal)
y = data{:,4};  % Cuarta columna (system_response)

% Filtración de los valores donde t >= 2 en el vector 
indices = t >= 2;  % Vector lógico para seleccionar datos desde t = 2
y_filtrado = y(indices);  % Extraer solo los valores de y correspondientes

% Calcular el promedio
promedio_y = mean(y_filtrado);

% Selección de puntos para graficar la recta tg
x1 = 1.26263;
y1 = 0.83727;
x2 = 0.454545;
y2 = 0.110512;

% Calcular la pendiente
m = (y2 - y1) / (x2 - x1);

% Ecuación de la recta tangente
% y = m * (x - x1) + y1

% Intersección con la línea 100% (promedio_y)
x_interseccion_100 = (promedio_y - y1) / m + x1; % Resolución de la ecuación y = promedio_y

% Intersección con la línea base (y = 0)
x_interseccion_base = -y1 / m + x1; % Resolución de la ecuación y = 0

% Calcular el 63.21% y el 28.4% de promedio_y
y_6321 = promedio_y * 0.6321;
y_284 = promedio_y * 0.284;

% Resolver para los valores de x correspondientes a estos porcentajes
x_6321 = (y_6321 - y1) / m + x1;
x_284 = (y_284 - y1) / m + x1;

% Ziegler and Nichols
Gzn = tf(0.661486, [1.103264 1], 'InputDelay', 0.331666);
yzn = lsim(Gzn, u, t);

% Millers
Gm = tf(0.661486, [0.697374 1], 'InputDelay', 0.331666);
ym = lsim(Gm, u, t);

% Analitico
Ga = tf(0.661486, [0.5760705 1], 'InputDelay', 0.4529695);
ya = lsim(Ga, u, t);

% Graficar todas las señales en el mismo gráfico
figure;

% Señales del archivo CSV
plot(t, u, 'b', 'LineWidth', 1.5); % ex_signal en azul
hold on;
plot(t, y, 'r', 'LineWidth', 1.5); % system_response en rojo

% Graficar las respuestas de los sistemas
plot(t, yzn, 'g', 'LineWidth', 1.5); % Respuesta Ziegler-Nichols en verde
plot(t, ym, 'b--', 'LineWidth', 1.5);  % Respuesta Millers en azul punteado
plot(t, ya, 'r--', 'LineWidth', 1.5);  % Respuesta Analítica en rojo punteado

% Graficar las líneas de referencia del sistema
yline(promedio_y, '--k', 'LineWidth', 1.5); % Línea punteada 100%
yline(0, '--k', 'LineWidth', 1.5); % Línea punteada 0%

% Graficar la recta tangente
x_recta = linspace(min(x1, x2) - 0.5, max(x1, x2) + 0.5, 100); % Expandimos el rango un poco
y_recta = m * (x_recta - x1) + y1; % Ecuación de la recta
plot(x_recta, y_recta, '--g', 'LineWidth', 1.5); % Línea punteada verde

% Marcar las intersecciones en el gráfico
plot(x_interseccion_100, promedio_y, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6); % Intersección 100%
plot(x_interseccion_base, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6); % Intersección 0%

% Marcar los puntos correspondientes al 63.21% y 28.4% en la recta tangente
plot(x_6321, y_6321, 'ms', 'MarkerFaceColor', 'm', 'MarkerSize', 6); % Punto 63.21%
plot(x_284, y_284, 'cs', 'MarkerFaceColor', 'c', 'MarkerSize', 6); % Punto 28.4%

% Configuración de la leyenda
legend('ex\_signal (u)', 'system\_response (y)', 'Ziegler-Nichols', 'Millers', ...
       'Analítico', 'Promedio de y (linea 100%)', 't = 0', 'Recta tangente', ...
       'Intersección 100%', 'Intersección 0%', '63.21% de 100%', '28.4% de 100%', ...
       'Location', 'best');

% Configuración del gráfico
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Respuestas del Sistema con Diferentes Métodos y Análisis de Intersecciones');
grid on;
hold off;