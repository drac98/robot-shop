<?php

declare(strict_types=1);

namespace Instana\RobotShop\Ratings\Service;

use Exception;
use Psr\Log\LoggerAwareInterface;
use Psr\Log\LoggerAwareTrait;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

/**
 * @Route("/catservice")
 */
class CatalogueService implements LoggerAwareInterface
{
    use LoggerAwareTrait;

    /**
     * @var string
     */
    private $catalogueUrl;
    private $rt_ratings_get_catalogue_product_sum;
    private $rt_ratings_get_catalogue_product_count;

    public function __construct(string $catalogueUrl)
    {
        $this->catalogueUrl = $catalogueUrl;
        $this->rt_ratings_get_catalogue_product_sum = 0.0;
        $this->rt_ratings_get_catalogue_product_count = 0;
    }

    /**
     * @Route("/metrics", methods={"GET"})
     */
    public function metrics(Request $request): Response
    {   $metrics = "rt_ratings_get_catalogue_product_sum ". strval($this->rt_ratings_get_catalogue_product_sum). " \rt_ratings_get_catalogue_product_count " . strval($this->rt_ratings_get_catalogue_product_count);
        header("Content-type: text/plain");
        return new JsonResponse($metrics,Response::HTTP_OK);
    }    

    public function checkSKU(string $sku): bool
    {   $start = microtime();
        $url = sprintf('%s/product/%s', $this->catalogueUrl, $sku);

        $opt = [
            CURLOPT_RETURNTRANSFER => true,
        ];
        $curl = curl_init($url);
        curl_setopt_array($curl, $opt);

        $data = curl_exec($curl);
        if (!$data) {
            $this->logger->error('failed to connect to catalogue');
            throw new Exception('Failed to connect to catalogue');
        }

        $status = curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
        $this->logger->info("catalogue status $status");

        curl_close($curl);
        $this->rt_ratings_get_catalogue_product_sum+= microtime()-$start;
        $this->rt_ratings_get_catalogue_product_count +=1;
        return 200 === $status;
    }
}
